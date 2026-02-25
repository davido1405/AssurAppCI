import 'package:assurappci/Models/Assurances.dart';
import 'package:assurappci/Repositories/AssuranceRepository.dart';
import 'package:flutter/foundation.dart';

class AssuranceViewModel extends ChangeNotifier {

   //1-Dépendances
   final AssuranceRepository _assuranceRepository;
   AssuranceViewModel(this._assuranceRepository);


   //2-Etats
   List<Assurances> _assurances=[];
   bool _chargementEnCours=false;
   String? _errorMessage;
   //3-Les getters
   List<Assurances> get assurances =>_assurances;
   bool? get chargementEnCours=>_chargementEnCours;
   String? get errorMessage=>_errorMessage;

  //4-Initialisation
   // Dans AssuranceViewModel, init() doit retourner la liste
   Future<List<Assurances>> init() async {
     _chargementEnCours = true;
     notifyListeners();

     try {
       _assurances = await _assuranceRepository.recupererAssurances() ?? [];
     } catch (e) {
       _errorMessage = 'Impossible de charger les assurances.';
     } finally {
       _chargementEnCours = false;
       notifyListeners();
     }

     return _assurances; // ← retourne la liste
   }
}