import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:career_guild/database/firestore.dart';

// Events
abstract class ImageUploadEvent {}

class SelectImage extends ImageUploadEvent {}

class ClearImage extends ImageUploadEvent {}

class SubmitPost extends ImageUploadEvent {
  final String message;
  final File? image;

  SubmitPost(this.message, this.image);
}

// States
abstract class ImageUploadState {}

class ImageUploadInitial extends ImageUploadState {}

class ImageSelected extends ImageUploadState {
  final File image;

  ImageSelected(this.image);
}

class ImageUploadError extends ImageUploadState {
  final String message;

  ImageUploadError(this.message);
}

class PostSubmitted extends ImageUploadState {}

class ImageUploadInProgress extends ImageUploadState {}

// Bloc
class ImageUploadBloc extends Bloc<ImageUploadEvent, ImageUploadState> {
  final FirestoreDatabase database = FirestoreDatabase();

  ImageUploadBloc() : super(ImageUploadInitial());

  @override
  Stream<ImageUploadState> mapEventToState(ImageUploadEvent event) async* {
    if (event is SelectImage) {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          yield ImageSelected(File(pickedFile.path));
        } else {
          yield ImageUploadError("No image selected.");
        }
      } catch (e) {
        yield ImageUploadError("Failed to pick image: $e");
      }
    } else if (event is ClearImage) {
      yield ImageUploadInitial();
    } else if (event is SubmitPost) {
      yield ImageUploadInProgress();

      try {
        String? imageUrl;

        if (event.image != null) {
          // Upload image to Firebase Storage
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final storageRef =
              FirebaseStorage.instance.ref().child('posts/$fileName');

          final uploadTask = await storageRef.putFile(event.image!);
          imageUrl = await uploadTask.ref.getDownloadURL();
        }

        // Add post to Firestore
        await database.addPost(event.message, imageUrl: imageUrl);

        yield PostSubmitted();
        yield ImageUploadInitial(); // Reset state after submission
      } catch (e) {
        yield ImageUploadError("Failed to submit post: $e");
      }
    }
  }
}

// Widget
class ImageUpload extends StatelessWidget {
  final TextEditingController textController;

  const ImageUpload({super.key, required this.textController});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageUploadBloc(),
      child: Column(
        children: [
          BlocBuilder<ImageUploadBloc, ImageUploadState>(
            builder: (context, state) {
              if (state is ImageSelected) {
                return Column(
                  children: [
                    Image.file(
                      state.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              } else if (state is ImageUploadError) {
                return Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                );
              } else if (state is ImageUploadInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            },
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.read<ImageUploadBloc>().add(SelectImage());
                },
                icon: const Icon(Icons.attach_file),
              ),
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: "Enter your post here...",
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final message = textController.text;
                  final currentState = context.read<ImageUploadBloc>().state;
                  File? image;

                  if (currentState is ImageSelected) {
                    image = currentState.image;
                  }

                  if (message.isNotEmpty) {
                    context
                        .read<ImageUploadBloc>()
                        .add(SubmitPost(message, image));
                    textController.clear();
                  }
                },
                icon: const Icon(Icons.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
