#!/usr/bin/env node

const http = require('http');
const https = require('https');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const PORT = 3000;
const DEPLOY_PATH = '/var/www/vocabu-rex';
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const GITHUB_REPO = process.env.GITHUB_REPO || 'your-username/vocabu_rex_mobile';

const server = http.createServer((req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  if (req.url === '/deploy' && req.method === 'POST') {
    let body = '';

    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', () => {
      try {
        const payload = JSON.parse(body);
        console.log(`[${new Date().toISOString()}] Webhook received from GitHub`);
        console.log('Payload:', payload);

        const runId = payload.run_id;
        const repo = payload.repo;

        if (!runId || !GITHUB_TOKEN) {
          console.error('Missing run_id or GITHUB_TOKEN');
          res.writeHead(400);
          res.end(JSON.stringify({ error: 'Missing configuration' }));
          return;
        }

        console.log('Downloading artifact from GitHub...');
        downloadAndDeployArtifact(repo, runId, (error) => {
          if (error) {
            console.error(`Deploy error: ${error.message}`);
            res.writeHead(500);
            res.end(JSON.stringify({ 
              success: false, 
              error: error.message
            }));
            return;
          }

          console.log(`[${new Date().toISOString()}] Deploy completed successfully`);
          res.writeHead(200);
          res.end(JSON.stringify({ 
            success: true, 
            message: 'Deploy completed'
          }));
        });

      } catch (error) {
        console.error('Error parsing webhook:', error);
        res.writeHead(400);
        res.end(JSON.stringify({ error: 'Invalid JSON' }));
      }
    });

  } else if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }));

  } else {
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

/**
 * Download artifact từ GitHub Actions
 */
function downloadAndDeployArtifact(repo, runId, callback) {
  const url = `https://api.github.com/repos/${repo}/actions/runs/${runId}/artifacts`;
  
  const options = {
    headers: {
      'Authorization': `token ${GITHUB_TOKEN}`,
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'Node.js'
    }
  };

  https.get(url, options, (res) => {
    let data = '';

    res.on('data', chunk => {
      data += chunk;
    });

    res.on('end', () => {
      try {
        const artifacts = JSON.parse(data);
        const webBuild = artifacts.artifacts.find(a => a.name === 'vocabu-web-build');

        if (!webBuild) {
          throw new Error('vocabu-web-build artifact not found');
        }

        console.log(`Found artifact: ${webBuild.name} (${webBuild.size_in_bytes} bytes)`);
        
        // Download artifact
        const downloadUrl = webBuild.download_url;
        const zipPath = '/tmp/vocabu-web-build.zip';

        downloadFile(downloadUrl, zipPath, options, (err) => {
          if (err) {
            return callback(err);
          }

          // Extract và deploy
          const extractCmd = `cd /tmp && unzip -o vocabu-web-build.zip && rm -rf ${DEPLOY_PATH}/* && cp -r vocabu-web-build/* ${DEPLOY_PATH}/ && rm -rf /tmp/vocabu-web-build* && echo "Deploy completed!"`;
          
          exec(extractCmd, (error, stdout, stderr) => {
            if (error) {
              return callback(error);
            }
            console.log('Extraction and deployment completed');
            callback(null);
          });
        });

      } catch (error) {
        callback(error);
      }
    });

  }).on('error', callback);
}

/**
 * Download file từ URL
 */
function downloadFile(url, filePath, options, callback) {
  https.get(url, options, (res) => {
    const fileStream = fs.createWriteStream(filePath);

    res.pipe(fileStream);

    fileStream.on('finish', () => {
      fileStream.close();
      console.log(`Downloaded to ${filePath}`);
      callback(null);
    });

    fileStream.on('error', callback);

  }).on('error', callback);
}

server.listen(PORT, () => {
  console.log(`\n🚀 GitHub Actions Webhook Listener running on port ${PORT}`);
  console.log(`📍 Webhook endpoint: http://your-vps-ip:${PORT}/deploy`);
  console.log(`💡 Health check: http://your-vps-ip:${PORT}/health\n`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
