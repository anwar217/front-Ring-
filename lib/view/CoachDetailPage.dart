import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:ringtounsi_mobile/model/coach.dart';
import 'package:ringtounsi_mobile/model/user.dart';
import 'package:ringtounsi_mobile/view/auth_provider.dart';

class CoachDetailPage extends StatelessWidget {
  final Coach coachData;
  final String? authToken;
  CoachDetailPage({required this.coachData , this.authToken});
   TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
     AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Coach'),
        backgroundColor: Color.fromARGB(0, 184, 23, 55),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe4f3e3), Color(0xff5ca9e9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Card(
                    color: Colors.white.withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage('assets/boxe.jpg'),
                          ),
                          SizedBox(height: 16.0),
                          ListTile(
                            title: Text(
                              coachData.nom,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.category),
                                    SizedBox(width: 4.0),
                                    Text('Catégorie de Boxing'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RatingBar.builder(
                                      initialRating: 2,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 16,
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        // Update the coach's rating
                                      },
                                    ),
                                    Text(" 2"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on),
                                    SizedBox(width: 4.0),
                                    Text('Adresse du Coach'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Description du Coach',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Commentaires et Avis',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 1, // Assuming coachData.comments.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                    "user1"), // Assuming userName exists in Comment model),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 16,
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            // Update the user's rating on this comment
                                          },
                                        ),
                                      ],
                                    ),
                                    Text("comment comment comment"),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          Row(),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                       _submitComment(authProvider);

                    },
                    child: Text('Post'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  Future<User> getCurrentUser(AuthProvider authProvider) async {

  try {
    print('Auth token before request: ${authProvider.authToken}');

    final response = await http.get(
      Uri.parse('http://192.168.63.65:3000/api/v1/users/whoami'),
      headers: {
        'Authorization': 'Bearer ${authProvider.authToken}',
      },
      
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = json.decode(response.body);
      final User currentUser = User.fromJson(userData);
      return currentUser;
    } else {
      print('Error response body: ${response.body}');
      throw Exception('Failed to load user data. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching user data: $error');
    throw Exception('Error fetching user data: $error');
  }
}
  
  
  Future<void> _submitComment(AuthProvider authProvider) async {
  try {
    final User connectedUser = await getCurrentUser(authProvider);

    if (connectedUser.id == null || coachData.id == null) {
      print('Connected user ID or coach ID is null.');
      return;
    }

    final int userId = connectedUser.id!;
    final int coachId = coachData.id;
    final String commentText = commentController.text.trim();

    // Ensure commentText is not null, use an empty string if it is
    final String commentToSend = commentText.isNotEmpty ? commentText : '';

    final response = await http.post(
      Uri.parse('http://192.168.63.65:3000/api/v1/users/add-comment'),
      headers: {
        'Authorization': 'Bearer ${authProvider.authToken}',
      },
      body: jsonEncode({
        'userId': userId,
        'coachId': coachId,
        'comment': commentToSend,
      }),
    );

    if (response.statusCode == 200) {
      print('Comment has been submitted successfully!');
    } else {
      print('Failed to submit comment. Status code: ${response.statusCode}');
    }
  } catch (error, stackTrace) {
    print('Error submitting comment: $error');
    print('StackTrace: $stackTrace');
    throw Exception('Error submitting comment: $error');
  }
}
}
