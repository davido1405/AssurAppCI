import 'package:assurappci/Models/Notifications.dart';
import 'package:assurappci/Repositories/NotificationsRespository.dart';
import 'package:flutter/cupertino.dart';

class Notificationsviewmodel extends ChangeNotifier {
  //Dépendance
  final NotificationsRepository _notificationsrepository;

  Notificationsviewmodel(this._notificationsrepository);

  //Etat

  List<Notifications> _notification = [];
  bool _chargementEnCours = false;
  int? _nombreNotifs;
  String? _errorMessage;

  //Getters
  List<Notifications> get notifications => _notification;

  bool get chargement => _chargementEnCours;

  int? get nombreNotifs => _nombreNotifs;

  String? get errorMessage => _errorMessage;

  //Initialisation
  Future<void> init(String code_utilisateur) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    //Maintenant on appel la méthode du répository
    try {
      _nombreNotifs =
          await _notificationsrepository.compterNotification(
            code_utilisateur,
          ) ??
          0;
    } catch (e) {
      _errorMessage =
          "Une erreur s'est produite lors du décompte des notifications";
      _nombreNotifs = 0;
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }
  }

  //Actions
  //Récupérer notifications
  Future<List<Notifications>?> recupererNotifications(String code_utilisateur,) async {
    _chargementEnCours = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final notifs = await _notificationsrepository.recupererNotifications(
        code_utilisateur
      );
      if(notifs!=null){
        _notification=notifs;
      }
      return _notification;
    } catch (e, stackTrace) {
      _chargementEnCours = false;
      _errorMessage =
          "Une erreur s'est produite lors de la récupération des notifications";
      print(stackTrace);
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }

    return [];
  }

  //Lire notification
  Future<void> lireNotification(String code_utilisateur, int id_annonce) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final notif = await _notificationsrepository.marquerCommeLu(
        id_annonce,
        code_utilisateur,
      );
    } catch (e, stackTrace) {
      _errorMessage = "Impossible de lire la notification";
      print('$e $stackTrace');
    } finally {
      notifyListeners();
    }
  }

  //Supprimer notifications
Future<void>supprimerNotification(String code_utilisateur,int id_annonce)async{
    _errorMessage=null;
    notifyListeners();
    try{
      await _notificationsrepository.supprimerNotification(id_annonce, code_utilisateur);
    }catch(e,stackTrace){
      _errorMessage="Impossible de supprimer la notification";
      print(e);
    }finally{
      notifyListeners();
    }
}
}
