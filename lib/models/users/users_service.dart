import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/util/services/services_reponse.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:confeitaria_divine_cacau/models/users/users.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersServices extends ChangeNotifier {
  static const String _collectionName = 'users';
  final CollectionReference<Map<String, dynamic>> _usersCollectionRef = FirebaseFirestore.instance.collection(_collectionName);
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  SharedPreferences? prefs;
  Users? currentUsers;

  //Constructor disparando o método loadCurrentUser
  UsersServices() {
    _loadCurrentUser();
  }

  //Obte a referência do documento do usuário atual
  DocumentReference get currentUsersDocRef {
    try {
      return FirebaseFirestore.instance.doc('$_collectionName/${_firebaseAuth.currentUser!.uid}');
    } catch(e) {
      debugPrint(e.toString());
      /*Fornece um usuário anônimo até que o usuário atual seja carregado, 
      dessa forma, não ocorrem erros de "Unexpected null value".*/
      return _firebaseFirestore.doc('$_collectionName/anonymous');
    }
  }
  
  //Obter o stream do usuário atual
  Stream<DocumentSnapshot> get currentUsersStream => currentUsersDocRef.snapshots();
   
  Future<bool> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _loadCurrentUser();
      return Future.value(true);
    }
    on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found') {
        debugPrint('Usário não existe');
      } else if(e.code == 'wrong-password') {
        debugPrint('A senha está incorreta');
      } else if(e.code == 'weak-password') {
        debugPrint('A senha é muito fraca');
      } else if(e.code == 'email-already-in-use') {
        debugPrint('O email já está em uso');
      } else if(e.code == 'invalid-email') {
        debugPrint('O email é inválido');
      } else if(e.code == 'operation-not-allowed') {
        debugPrint('Operação não permitida');
      } else if (e.code == 'too-many-requests') {
        debugPrint('Muitas requisições');
      } else if (e.code == 'network-request-failed') {
        debugPrint('Falha na conexão');
      } else {
        debugPrint('Erro desconhecido');
      }
      return Future.value(false);
    }
  }
  
  Future<bool> signUp(String userName, String email, String password, 
      String cpf, String? gender, DateTime? birthday, String? phone) async {
    try {
      User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).user;

      Users newUser = Users(
        id: user!.uid,
        email: user.email,
        password: password,
        userName: userName,
        cpf: cpf,
        gender: gender,
        birthday: birthday,
        phone: phone,
      );
      
      if(await saveUser(newUser)) {
        signIn(email, password);
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    }
    on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found') {
        debugPrint('Usuário não existe');
      } else if(e.code == 'wrong-password') {
        debugPrint('A senha está incorreta');
      } else if(e.code == 'weak-password') {
        debugPrint('A senha é muito fraca');
      } else if(e.code == 'email-already-in-use') {
        debugPrint('O email já está em uso');
      } else if(e.code == 'invalid-email') {
        debugPrint('O email é inválido');
      } else if(e.code == 'operation-not-allowed') {
        debugPrint('Operação não permitida');
      } else if (e.code == 'too-many-requests') {
        debugPrint('Muitas requisições');
      } else if (e.code == 'network-request-failed') {
        debugPrint('Falha na conexão');
      } else {
        debugPrint('Erro desconhecido');
      }
      return Future.value(false);
    }
  }

  Future<bool> saveUser(Users users) async {
    try {
      await _usersCollectionRef.doc(users.id).set(users.toJson());
      return Future.value(true);
    } catch(e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  Future<ServicesReponse> updateUserData(String usersId, Users users) async {
    try {
      users.id ??= usersId; 
      users.password ??= await _usersCollectionRef.doc(usersId).get().then((value) => value.data()!['password']);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(_usersCollectionRef.doc(usersId), users.toJson());
        currentUsers = users;
      },
      timeout: const Duration(seconds: 10), maxAttempts: 1);
      notifyListeners();
      return Future.value(ServicesReponse(status: true));
    } catch(e) {
      debugPrint(e.toString());
      return Future.value(ServicesReponse(status: false));
    }
  }

  Future<bool> deleteUser() async {
    try {
      //Reautentica o usuário para evitar erro de "requires recent login"
      await reauthenticate();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.delete(_usersCollectionRef.doc(currentUsers?.id));
        await _firebaseAuth.currentUser!.delete();
        currentUsers = null;
        prefs!.remove('id');
      },
      timeout: const Duration(seconds: 10), maxAttempts: 1);
      notifyListeners();
      return Future.value(true);
    } catch(e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  _loadCurrentUser() async {
    User? firebaseCurrentUser = _firebaseAuth.currentUser;
    DocumentSnapshot? docUser;
    prefs = await SharedPreferences.getInstance();

    if(firebaseCurrentUser != null) {
      prefs!.setString('id', firebaseCurrentUser.uid);

      /*Predefinindo o usuário atual com o ID pelo menos, para caso haja verificação de usuário
      logado, não ocorra de ser entendiado como não logado(pelo fato da obtenção completa dos
      dados do usuário ser assíncrona, ou seja, demorar um tempo para ser concluída).*/
      currentUsers = Users(
        id: firebaseCurrentUser.uid
      );
      docUser = await _usersCollectionRef.doc(firebaseCurrentUser.uid).get();
    } else if(prefs!.containsKey('id') && prefs!.getString('id') != null) {
      String? id = prefs!.getString('id');
      currentUsers = Users(
        id: id
      );
      docUser = await _usersCollectionRef.doc(id).get();
    }
    
    if(docUser != null){
      currentUsers = Users.fromJson(docUser);
      notifyListeners(); 
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    currentUsers = null;
    prefs!.remove('id');
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return Future.value(true);
    } on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found') {
        debugPrint('Usuário não existe');
      } else if(e.code == 'invalid-email') {
        debugPrint('O email é inválido');
      } else if (e.code == 'network-request-failed') {
        debugPrint('Falha na conexão');
      } else {
        debugPrint('Erro desconhecido');
      }
      return Future.value(false);
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      //Reautentica o usuário para evitar erro de "requires recent login"
      await reauthenticate();
      await _firebaseAuth.currentUser!.updatePassword(newPassword);
      await _usersCollectionRef.doc(currentUsers?.id).set({
        'password': newPassword,
      }, SetOptions(merge: true));
      currentUsers!.password = newPassword; 
      return Future.value(true);
    } catch(e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  Future reauthenticate() async {
    try {
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: currentUsers!.email!,
          password: currentUsers!.password!,
        ),
      );
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  /* --- Validações --- */
  static const String passwordMismatchMessage = 'As senhas não coincidem.';

  static String? validateUserName(String? userName) {
    if(userName == null || userName.isEmpty) {
      return 'Insira um nome para seu perfil.';
    }
    return null;
  }

  Future<String?> validateEmail(String? email, 
      {bool disregardExistingEmail = false, bool isUpdate = false}) async {
    if(!EmailValidator.validate(email!)) {
      return 'Esse e-mail é inválido. O formato correto é assim: exemplo@email.com';
    } else if (!disregardExistingEmail 
        && (isUpdate && email != currentUsers!.email || isUpdate == false) && await emailAlreadyExists(email)) {
      return 'Este endereço já está vinculado a uma conta existente.';
    }
    return null;
  }

  static Future<bool> emailAlreadyExists(String email) async {
    email = email.toLowerCase();
    QuerySnapshot query = await FirebaseFirestore.instance.collection(_collectionName).where('email', isEqualTo: email).get();
    if (query.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static String? validatePassword(String? password) {
    if(password == null || password.isEmpty || password.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    } 
    return null;
  }

  static bool passwordMatchesCurrentPassword(BuildContext context, String password) {
    if(password == Provider.of<UsersServices>(context, listen: false).currentUsers!.password) {
      return true;
    } 
    return false;
  }
  
  static String? validateCpf(String? cpf) {
    if(cpf == null || cpf.isEmpty) {
      return 'Insira um CPF válido.';
    } else if(!CPFValidator.isValid(cpf)) {
      return 'CPF inválido';
    }
    return null;
  }

  static String? validateGender(String? gender) {
    if(gender == null || gender.isEmpty) {
      return null;
    } else if(!Genders.getGendersList().contains(gender)) {
      return 'Selecione um gênero válido.';
    } 
    return null;
  }

  static String? validateBirthday(String? birthday) {
    if(birthday == null || birthday.isEmpty) {
      return null;
    } else {
      try {
        DateTime dateTimeBirthday =  DateFormat("dd/MM/yyyy").parse(birthday);
        if(dateTimeBirthday.isBefore(DateTime(1900)) || dateTimeBirthday.isAfter(DateTime.now())) {
          return 'Data inválida: insira uma data entre 01/01/1900 e a data atual.';
        }
        return null;
      } on FormatException {
        return 'Insira uma data válida.';
      }
    } 
  }

  static String? validatePhone(String? phone) {
    String deformattedPhone = phone!.replaceAll(RegExp(r'[^0-9]'), '');
    if(deformattedPhone.isEmpty) {
      return null;
    } else if(deformattedPhone.length == 10 || deformattedPhone.length == 11) {
      return null;
    }
      return 'Insira um telefone válido.';
  }  
}
