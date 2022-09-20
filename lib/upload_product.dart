import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadProduct extends StatefulWidget {
  const UploadProduct({Key? key}) : super(key: key);

  @override
  State<UploadProduct> createState() => _UploadProductState();
}

class _UploadProductState extends State<UploadProduct> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _pdName, _pdDes, _pdActPrice, _pdDisPrice, _pdImg;
  bool _btnLoad = false,
      _shwprw = false,
      isLoading = false,
      isAvailable = false;
  File? _image;
  final picker = ImagePicker();

  Future<void> openGallery() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _image = File(image.path);
        debugPrint(_image.toString());
      } else {
        snackBar('No image selected.');
      }
    });
  }

  Future<void> openCamera() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (image != null) {
        _image = File(image.path);
        debugPrint(_image.toString());
      } else {
        snackBar('No image captured.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Product'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Column(
              children: [
                // Center(child: Text('Add Product', style: kStyle)),
                const SizedBox(height: 20),
                AdminTextField(controller: _pdName, label: 'Product Name'),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _pdDes,
                  label: 'Product Description',
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AdminTextField(
                        controller: _pdActPrice,
                        label: 'Actual Price',
                        prefixText: '₦',
                        maxLength: 7,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: AdminTextField(
                        controller: _pdDisPrice,
                        label: 'Discout',
                        prefixText: '₦',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Is available'),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: isAvailable,
                      onChanged: (v) {
                        setState(() {
                          isAvailable = v!;
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _pdImg,
                  label: 'Product Image Url',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 10),
                const Text('Or'),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return imagePick();
                      },
                    );
                  },
                  child: const Text('Select Image to upload'),
                ),
                const SizedBox(height: 10),
                _image == null
                    ? const Text('No image selected.')
                    : Image.file(_image!, height: 300),
                const SizedBox(height: 10),
                !isLoading
                    ? _image != null
                        ? ElevatedButton(
                            child: const Text("Upload Image"),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              Reference ref = FirebaseStorage.instance.ref();
                              String imgName = _image!
                                  .toString()
                                  .substring(_image.toString().lastIndexOf("/"),
                                      _image.toString().lastIndexOf("."))
                                  .replaceAll("/", "");
                              TaskSnapshot addImg = await ref
                                  .child("prdImages/$imgName")
                                  .putFile(_image!);
                              if (addImg.state == TaskState.success) {
                                final String imgUrl =
                                    await addImg.ref.getDownloadURL();
                                debugPrint(imgUrl);
                                setState(() {
                                  isLoading = false;
                                  _pdImg!.text = imgUrl;
                                });
                                snackBar("Image uploaded");
                              }
                            })
                        : const Center()
                    : const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                        ),
                      ),
                const SizedBox(height: 20),
                _btnLoad
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MaterialButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _btnLoad = true;
                                });
                                try {
                                  await FirebaseFirestore.instance
                                      .collection("items")
                                      .add({
                                    "name": _pdName!.text,
                                    "description": _pdDes!.text,
                                    "price": _pdActPrice!.text,
                                    "discount": _pdDisPrice!.text,
                                    "prodimg": _pdImg!.text,
                                    "available": isAvailable,
                                    'date': DateTime.now().toString(),
                                  }).then((value) {
                                    setState(() {
                                      _btnLoad = false;
                                    });
                                    return snackBar(
                                        'Product added successfully, Yay!');
                                  }).catchError((error) => snackBar(
                                          "Failed to add product: $error"));
                                } on SocketException catch (_) {
                                  snackBar('No internet');
                                } on TimeoutException catch (_) {
                                  snackBar('Time out');
                                } catch (e) {
                                  snackBar('$e');
                                }
                                setState(() {
                                  _btnLoad = false;
                                });
                              }
                            },
                            color: Colors.blue,
                            child: const Text('Add Product'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _shwprw = !_shwprw;
                                });
                              }
                            },
                            child: const Text('Preview product'),
                          )
                        ],
                      ),
                const SizedBox(height: 10),
                Visibility(
                  visible: _shwprw,
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 1),
                          color: Colors.grey.shade400,
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12)),
                            image: DecorationImage(
                              image: NetworkImage(_pdImg!.text),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_pdName!.text,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                _pdDes!.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "₦${_pdActPrice!.text}",
                                    style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600,
                                      // decoration: TextDecoration.lineThrough,
                                      decorationStyle:
                                          TextDecorationStyle.double,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    color: Colors.blue.withOpacity(0.2),
                                    padding: const EdgeInsets.all(2.3),
                                    child: const Text('-32%'),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Discount ${_pdDisPrice!.text}%",
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                  child: MaterialButton(
                                minWidth: double.infinity,
                                onPressed: () {},
                                color: Colors.blue,
                                child: const Text('Buy Now!'),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  snackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    ));
  }

  imagePick() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pick your choice'),
          const SizedBox(height: 6),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  openGallery();
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    children: const [
                      CircleAvatar(radius: 24, child: Icon(Icons.photo_album)),
                      SizedBox(height: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  openGallery();
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    children: const [
                      CircleAvatar(radius: 24, child: Icon(Icons.camera_alt)),
                      SizedBox(height: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pdName = TextEditingController();
    _pdDes = TextEditingController();
    _pdActPrice = TextEditingController();
    _pdDisPrice = TextEditingController();
    _pdImg = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _pdName!.dispose();
    _pdDes!.dispose();
    _pdActPrice!.dispose();
    _pdDisPrice!.dispose();
    _pdImg!.dispose();
  }
}

class AdminTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label, prefixText;
  final int? maxLines, maxLength;
  final TextInputType? keyboardType;
  const AdminTextField({
    super.key,
    this.controller,
    this.label,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Empty field detected';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(5, 8, 10, 5),
        isDense: true,
        labelText: '$label',
        counterText: '',
        prefixText: prefixText,
      ),
    );
  }
}
