import 'package:moviedb_app/model/movie_model.dart';

abstract class MovieRepository {
  Future<List<MovieModel>> getUpcoming();
  Future<bool> addRating(String id, double rate);
}
