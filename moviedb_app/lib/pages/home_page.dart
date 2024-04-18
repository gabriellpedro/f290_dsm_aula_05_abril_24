// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:moviedb_app/repositories/movie_repository_impl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _avaliacao = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: context.read<MovieRepositoryImpl>().getUpcoming(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CircularProgressIndicator(),
              ),
            );
          }

          var data = snapshot.data;

          if (data?.isEmpty ?? true) {
            return const Center(
              child: Card(
                  child: Padding(
                padding: EdgeInsets.all(17.0),
                child: Text(
                  'Preencha o arquivo .env na raiz do projeto com a API_KEY e TOKEN para que as requisições possam e ser autenticadas corretamente, assim voce poderá consultar sua avaliações de favoritos posteriormente.',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              )),
            );
          }

          return GridView.builder(
            itemCount: data?.length ?? 0,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 4,
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              _avaliacao = data![index].voteAverage;
              return GestureDetector(
                onTap: () {
                  print('Filme selecionado');
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    FadeInImage(
                      fadeInCurve: Curves.bounceInOut,
                      fadeInDuration: const Duration(milliseconds: 500),
                      image: NetworkImage(data![index].getPostPathUrl()),
                      placeholder: const AssetImage('assets/images/logo.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black12,
                        padding: EdgeInsets.all(8.0),
                        child: RatingBar.builder(
                          initialRating: _avaliacao,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 10,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(
                              () {
                                _avaliacao = rating;
                              },
                            );
                            _AvisoAvaliacao(context, rating, data![index].id);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _AvisoAvaliacao(BuildContext context, double rating, int movieId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enviar avaliação'),
          content: Text('Será enviada a avaliação $rating para este filme?'),
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          actions: <Widget>[
            Row(
              children: [
                OutlinedButton(
                  child: const Text('Sair'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 120),
                FilledButton(
                  onPressed: () {
                    _enviarAvaliacao(rating, movieId);
                    Navigator.of(context).pop();
                  },
                  child: Text('Enviar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _enviarAvaliacao(double rating, int movieId) async {
    bool isSuccess = await context
        .read<MovieRepositoryImpl>()
        .addRating(movieId.toString(), rating);
    if (isSuccess) {
      print('Filme avaliado com Sucesso.');
    } else {
      print('Falha ao enviar avaliação.');
    }
  }
}
