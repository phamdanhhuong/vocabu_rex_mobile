allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    configurations.configureEach {
        resolutionStrategy {
            force("androidx.glance:glance:1.1.1")
            force("androidx.glance:glance-appwidget:1.1.1")
        }
    }

    val configureTargets = {
        project.tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
        project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }

    if (project.state.executed) {
        configureTargets()
    } else {
        project.afterEvaluate {
            configureTargets()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
