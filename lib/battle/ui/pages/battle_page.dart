import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/battle_arena_page.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({Key? key}) : super(key: key);
  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  @override
  void initState() {
    super.initState();
    context.read<BattleBloc>().add(BattleLoadStats());
    context.read<FabCubit>().hide();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BattleBloc, BattleState>(
      listenWhen: (p, c) => c is BattleMatchReady || c is BattleRoundActive,
      listener: (ctx, st) {
        if (st is BattleMatchReady || st is BattleRoundActive) {
          Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const BattleArenaPage()));
        }
      },
      builder: (ctx, st) {
        return Container(
          color: AppColors.snow,
          child: SafeArea(
            child: st is BattleSearching ? _searching(ctx) : _landing(ctx, st),
          ),
        );
      },
    );
  }

  Widget _landing(BuildContext ctx, BattleState st) {
    final stats = st is BattleStatsLoaded ? st.stats : null;
    final history = st is BattleStatsLoaded ? st.history : [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 16),
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF4B4B)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFFFF4B4B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 56),
        ),
        const SizedBox(height: 20),
        const Text('Thi Đấu Trực Tuyến', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.bodyText, fontFamily: 'DuolingoFeather')),
        const SizedBox(height: 8),
        const Text('Đấu quiz tiếng Anh 1v1 với người chơi khác!', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.wolf, fontFamily: 'DuolingoFeather')),
        const SizedBox(height: 28),
        if (stats != null) _statsRow(stats),
        const SizedBox(height: 24),
        AppButton(
          label: '⚔️  TÌM TRẬN ĐẤU',
          onPressed: () => ctx.read<BattleBloc>().add(BattleFindMatch()),
          variant: ButtonVariant.alternate,
          width: MediaQuery.of(ctx).size.width * 0.75,
          size: ButtonSize.large,
        ),
        const SizedBox(height: 12),
        const Text('Miễn phí • 5 câu hỏi • 15 giây/câu', style: TextStyle(fontSize: 13, color: AppColors.hare, fontFamily: 'DuolingoFeather')),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 32),
          _sectionTitle('Trận đấu gần đây'),
          const SizedBox(height: 12),
          ...history.map((h) => _historyCard(h)),
        ],
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _statsRow(dynamic s) {
    return Row(children: [
      Expanded(child: _statCard('Thắng', '${s.wins}', AppColors.featherGreen)),
      const SizedBox(width: 10),
      Expanded(child: _statCard('Thua', '${s.losses}', AppColors.cardinal)),
      const SizedBox(width: 10),
      Expanded(child: _statCard('Hòa', '${s.draws}', AppColors.macaw)),
      const SizedBox(width: 10),
      Expanded(child: _statCard('Streak', '${s.winStreak}🔥', AppColors.bee)),
    ]);
  }

  Widget _statCard(String label, String value, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.2))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c, fontFamily: 'DuolingoFeather')),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.wolf, fontWeight: FontWeight.w600, fontFamily: 'DuolingoFeather')),
      ]),
    );
  }

  Widget _sectionTitle(String t) {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.swan)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.bodyText, fontFamily: 'DuolingoFeather'))),
      const Expanded(child: Divider(color: AppColors.swan)),
    ]);
  }

  Widget _historyCard(dynamic h) {
    final Color rc; final String rt; final IconData ri;
    switch (h.result) { case 'WIN': rc = AppColors.featherGreen; rt = 'Thắng'; ri = Icons.emoji_events; break; case 'LOSE': rc = AppColors.cardinal; rt = 'Thua'; ri = Icons.close; break; default: rc = AppColors.macaw; rt = 'Hòa'; ri = Icons.handshake; }
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.snow, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.swan), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: rc.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(ri, color: rc, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h.opponent?.displayName ?? (h.isBot ? 'Bot' : 'Unknown'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.bodyText, fontFamily: 'DuolingoFeather')),
          Text('${h.myScore} - ${h.opponentScore} • +${h.xpEarned} XP', style: const TextStyle(fontSize: 13, color: AppColors.wolf, fontFamily: 'DuolingoFeather')),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: rc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(rt, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: rc, fontFamily: 'DuolingoFeather'))),
      ]),
    );
  }

  Widget _searching(BuildContext ctx) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.macaw, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.macaw.withOpacity(0.3), blurRadius: 20)]),
        child: const Icon(Icons.search, color: Colors.white, size: 40)),
      const SizedBox(height: 32),
      const Text('Đang tìm đối thủ...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.bodyText, fontFamily: 'DuolingoFeather')),
      const SizedBox(height: 8),
      const DotLoadingIndicator(color: AppColors.macaw, size: 12),
      const SizedBox(height: 32),
      TextButton(onPressed: () => ctx.read<BattleBloc>().add(BattleCancelSearch()),
        child: const Text('Hủy tìm kiếm', style: TextStyle(fontSize: 16, color: AppColors.cardinal, fontWeight: FontWeight.w600, fontFamily: 'DuolingoFeather'))),
    ]));
  }
}
