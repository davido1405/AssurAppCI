import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/Models/Session.dart';
import 'package:assurappci/Screens/General/DetailsPharmacie.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/PharmacieViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.microtask(()=>recupererPharmacie());
  }

  String filtre="tous";
  List<Pharmacie>toutesPharmacies=[];
  Session? userConnecte;

  Future<void>recupererPharmacie()async{
    final pharmacieViewModel=context.read<PharmacieViewModel>();
    await pharmacieViewModel.init();

    if(pharmacieViewModel.errorMessage==null){

      switch (filtre) {
        case "tous":
          if (mounted) {
            setState(() {
              toutesPharmacies = pharmacieViewModel.pharmacies;
            });
          }
        case "assurance":
          final assurance = context.read<AuthViewModel>().session?.nomAssuranceUtilisateur ?? '';
          if (mounted) {
            setState(() {
              toutesPharmacies = pharmacieViewModel.pharmacies
                  .where((p) => p.assuranceAcceptees
                  .any((a) => a.contains(assurance)))
                  .toList();
            });
          }
        case "adresse":
          final adresse = context.read<AuthViewModel>().session?.adresseUtilisateurFournit ?? '';
          if (mounted) {
            setState(() {
              toutesPharmacies = pharmacieViewModel.pharmacies
                  .where((p) => p.adresseFournit.contains(adresse))
                  .toList();
            });
          }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      child: SafeArea(child: RefreshIndicator(
          onRefresh: toutePharmacie,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics(),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          children: [
                          Column(
                            mainAxisSize:MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Salut ! Bienvenu(e)",style: TextStyle(fontSize: 20.sp,color: Colors.grey[500]),),
                              Text(context.watch<AuthViewModel>().session?.nomUtilisateur ?? 'Utilisateur',style: TextStyle(fontSize: 25.sp,fontWeight: FontWeight.bold),)
                            ],
                          ),
                          Container(
                            child: Row(
                              children: [
                                Badge(label:Text('2'),
                                    child: IconButton(onPressed: (){
                                      //Navigator.push(context, MaterialPageRoute(builder: (context)=>Notification()));
                                    }, icon: Icon(Icons.notifications_outlined))),
                                IconButton(onPressed: (){}, icon: Icon(Icons.settings))
                              ],
                            ),
                          )
                        ],),
                        SizedBox(height: 15.h,),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Rechercher",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            )
                          ),
                        ),
                        SizedBox(height: 30.h,),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              TextButton.icon(onPressed: (){
                                setState(() {
                                  filtre="tous";
                                });
                              }, label: Text("Toutes les pharmacies",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: filtre=="tous"?Colors.white:Colors.deepOrangeAccent,
                              ),),icon: Icon(CupertinoIcons.globe,color: filtre=="tous"?Colors.white:Colors.deepOrangeAccent,),style: TextButton.styleFrom(
                                  side:filtre=="tous"?null: BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 2
                                  ),
                                  backgroundColor: filtre=="tous"?Colors.deepOrangeAccent:Colors.white
                              ),),
                              SizedBox(width: 15.w,),
                              TextButton.icon(onPressed: (){
                                setState(() {
                                  filtre="adresse";
                                });
                              }, label: Text("Près de moi",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: filtre=="adresse"?Colors.white:Colors.deepOrangeAccent,
                              ),),icon: Icon(filtre=="adresse"?Icons.location_on:Icons.location_on_outlined,color: filtre=="adresse"?Colors.white:Colors.deepOrangeAccent,),style: TextButton.styleFrom(
                                  side:filtre=="adresse"?null: BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 2
                                  ),
                                  backgroundColor: filtre=="adresse"?Colors.deepOrangeAccent:Colors.white
                              ),),
                            SizedBox(width: 15.w,),
                              TextButton.icon(onPressed: (){
                                setState(() {
                                  filtre="assurance";
                                });
                              }, label: Text("Assurances",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: filtre=="assurance"?Colors.white:Colors.deepOrangeAccent,
                              ),),icon: Icon(filtre=="assurance"?Icons.shield:Icons.shield_outlined,color: filtre=="assurance"?Colors.white:Colors.deepOrangeAccent,),style: TextButton.styleFrom(
                                  side:filtre=="assurance"?null: BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 2
                                  ),
                                  backgroundColor: filtre=="assurance"?Colors.deepOrangeAccent:Colors.white
                              ),),
                          ],),)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15.h,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text("Liste de pharmacies",style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.sp
                        ),),
                        Text("${toutesPharmacies.length}",style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500
                        ),)
                      ],),
                      SizedBox(height: 15.h,),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: toutesPharmacies.length,
                          itemBuilder: (context,index){
                        return cardPharmacie(toutesPharmacies[index]);
                      })
                    ],
                  ),
                )
              ],
            ),
          ),
        ),),
    );
  }

  Future<void> toutePharmacie() async {
  }

  Widget cardPharmacie(Pharmacie pharmacie){
    return GestureDetector(
      onTap: (){
        if(mounted){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Detailspharmacie(pharmacie: pharmacie)));
        }
        },
      child: SizedBox(
        height: 110.h,
        child: Card(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          ClipRRect(borderRadius: BorderRadius.circular(12.r),child: Image.asset("assets/images/a.jpg",width: 100.w,height: 50.h,),),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pharmacie.nomPharmacie,style: TextStyle(
                  fontWeight: FontWeight.bold,fontSize: 20.sp
              ),),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,color: Colors.grey,),
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Text(pharmacie.adresseFournit,style: TextStyle(
                        fontWeight: FontWeight.w500,
                      color: Colors.grey[500]
                    ),overflow: TextOverflow.ellipsis,),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Container(
                  height: 35.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: pharmacie.libelleStatut=="Actif"?Colors.green:Colors.red,
                    borderRadius: BorderRadius.circular(12.r)
                  ),
                  child: Center(child: Text("Ouvert 07h-22h",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),)),
                ),
                SizedBox(width: 10.w,),
                Container(
                  height: 30.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.circular(12.r)
                  ),
                  child: Center(child: Text("1.2km",style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),)),
                ),SizedBox(width: 10.w,),
                GestureDetector(
                    onTap: (){
                      print("Absorbé");
                    },
                    child: Text("Détails",style: TextStyle(color: Colors.deepOrangeAccent),),
                  ),
              ],)
            ],
          )
                ],),),
      ),
    );
  }
}
