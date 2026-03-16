import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/Screens/General/Carte.dart';
import 'package:assurappci/ViewModels/AuthViewModel.dart';
import 'package:assurappci/ViewModels/NewsletterViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Detailspharmacie extends StatefulWidget {
  final Pharmacie pharmacie;
  const Detailspharmacie({super.key, required this.pharmacie});

  @override
  State<Detailspharmacie> createState() => _DetailspharmacieState();
}

class _DetailspharmacieState extends State<Detailspharmacie> {

  Future<void>sabonner()async{
    final sabonne=await context.read<Newsletterviewmodel>();
    try{
      sabonne.sabonner(widget.pharmacie.codePharmacie,context.read<AuthViewModel>().session!.codeUtilisateur);

      if(sabonne.errorMessage==null){
        return showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(title: Text("Satut abonnement"),
          content: Text("Abonnement éffectué avec succès !"),actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text("Compris"))
            ],);
        });
      }else{
        return showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(title: Text("Satut abonnement"),
            content: Text("${sabonne.errorMessage}"),actions: [
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("Compris"))
            ],);
        });
      }
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body:SafeArea(child: RefreshIndicator(
        onRefresh: refreshed,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 390.h,
                child: Stack(
                  children: [
                    Positioned(child: ClipRRect(child: Image.asset("assets/images/a.jpg"),)),
                    Positioned(
                      top: 15,
                        left: 10,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5
                                )
                              ]
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Icon(Icons.arrow_back),
                            ),
                          ),
                        )),
                    Positioned(
                        top: 15.w,
                        left: 350.w,
                        child: GestureDetector(
                          onTap: (){
                            print("Sahed bouton taped");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Icon(Icons.share_outlined),
                            ),
                          ),
                        )),
                    Positioned(
                      top: 220.h,
                        left: 25.w,
                        child: Container(
                          width: 350.w,decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.grey[500] as Color,blurRadius: 10)]
                        ),
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.pharmacie.nomPharmacie,style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 30.sp
                                ),overflow: TextOverflow.ellipsis,),
                                SizedBox(height: 5.h,),
                                Container(
                                  height: 35.h,
                                  width: 160.w,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12.r)
                                  ),
                                  child: Center(child: Text("Ouvert 07h-22h",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),)),
                                ),SizedBox(height: 10.h,),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,color: Colors.grey,),
                                    FittedBox(
                                      fit: BoxFit.fill,
                                      child: Text(widget.pharmacie.adresseFournit??"Aucune adresse fournit pour le moment",style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[500]
                                      ),overflow: TextOverflow.ellipsis,),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),),)
                  ],
                ),
              ),
              SizedBox(height: 10.h,),
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: ScrollPhysics(),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: (){

                        },
                          child: cardAction("Appeler", Icon(CupertinoIcons.phone,color: Colors.blue,size: 40.r,), Colors.lightBlueAccent)),
                      SizedBox(width: 10.w,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Carte()));
                        },
                          child: cardAction("Itinéraire", Icon(CupertinoIcons.paperplane,color: Colors.orange,size: 40.r,), Colors.orangeAccent)),
                      SizedBox(width: 10.w,),
                      GestureDetector(
                        onTap: ()async{
                          sabonner();
                        },
                          child: cardAction("S'abonner", Icon(Icons.notification_add_outlined,color: Colors.blue,size: 40.r,), Colors.grey)),

                    ],
                  ),
                ),
              ),
              //SizedBox(height: 20.h,),
              Padding(padding: EdgeInsets.all(20.w),
              child: Text("Assurances acceptées",style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.w500),)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: widget.pharmacie.assuranceAcceptees.asMap().entries.map((entry) {
                    final index = entry.key;
                    final assurance = entry.value;
                    return Column(
                      children: [
                        cardAssurance(assurance),
                        if (index < widget.pharmacie.assuranceAcceptees.length - 1)
                          Divider(color: Colors.grey[200], thickness: 2),
                      ],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text("Contact Pharmacie",style: TextStyle(fontSize: 20.sp,
                    fontWeight: FontWeight.w500
                ),),
              ),
              SizedBox(height: 20.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                    )]
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Column(
                      children: [
                        Row(children: [
                          Icon(CupertinoIcons.phone,color: Colors.deepOrangeAccent,),
                          SizedBox(width: 15.w,),
                          Text(widget.pharmacie.numeroPharmacie,style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp
                          ),),
                        ],),
                        SizedBox(height: 15.h,),
                        Row(children: [
                          Icon(CupertinoIcons.mail_solid,color: Colors.blue,),
                          SizedBox(width: 15.w,),
                          Text(widget.pharmacie.emailPharmacie!,style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp
                          ),),
                        ],)
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.w),
                child: Center(child: ElevatedButton.icon(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Carte()));
                }, label: Text("Voir sur la carte",style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  shadows: [BoxShadow(
                    color: Colors.deepOrangeAccent,
                    blurRadius: 15,
                  )]
                ),),icon: Icon(Icons.map_outlined,color: Colors.white,),style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent
                ),)),
              )
            ],
          ),
        ),
      )),);
  }

  Future<void> refreshed() async {
  }

  Widget cardAction(String nom,Icon iconP,Color couleurCercle){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.grey,
          blurRadius: 5
        )]
      ),
      child: Padding(padding: EdgeInsets.all(25.w),child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(decoration:BoxDecoration(
            shape: BoxShape.circle,
            color: couleurCercle
          ),child: Padding(padding: EdgeInsets.all(12.w),
          child: iconP),),
          SizedBox(height: 10.h,),
          Text(nom,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15.sp),),
        ],
      ),),
    );
  }

  Widget cardAssurance(String assurances){
    return Padding(
    padding: EdgeInsets.all(15.w),
    child: ListTile(
      leading: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.grey[300]
        ),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Icon(Icons.shield_outlined,color: Colors.green,),
        ),
      ),
      title: Text(assurances,style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w500
      ),),
      trailing: Icon(Icons.check_circle,color:Colors.green,),
    )
        );
  }
}
