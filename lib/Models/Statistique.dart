import 'package:assurappci/Models/Assurances.dart';

class StatistiquesPharmacie {
  final int totalVues;
  final int totalAbonnes;
  final int annoncesActives;
  final int newslettersEnvoyees;
  //final List<VueParJour> vuesParJour;
  //final List<EvolutionAbonne> evolutionAbonnes;
  final List<Assurances> assurances;

  StatistiquesPharmacie({
    required this.totalVues,
    required this.totalAbonnes,
    required this.annoncesActives,
    required this.newslettersEnvoyees,
    //required this.vuesParJour,
    //required this.evolutionAbonnes,
    //required this.topAnnonces,
    required this.assurances,
  });

  factory StatistiquesPharmacie.fromJson(Map<String, dynamic> json) {
    return StatistiquesPharmacie(
      totalVues: json['stats_base']['total_vues'] ?? 0,
      totalAbonnes: json['stats_base']['total_abonnes'] ?? 0,
      annoncesActives: json['stats_base']['annonces_actives'] ?? 0,
      newslettersEnvoyees: json['stats_base']['newsletters_envoyees'] ?? 0,
      /**
      vuesParJour: (json['vues_par_jour'] as List)
          .map((e) => VueParJour.fromJson(e))
          .toList(),
      evolutionAbonnes: (json['evolution_abonnes'] as List)
          .map((e) => EvolutionAbonne.fromJson(e))
          .toList(),
      topAnnonces: (json['top_annonces'] as List)
          .map((e) => AnnoncePopulaire.fromJson(e))
          .toList(),
    **/
      assurances: (json['assurances'] as List)
          .map((e) => Assurances.fromJson(e))
          .toList(),
    );
  }
}