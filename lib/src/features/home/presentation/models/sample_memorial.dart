/// Sample memorial entry representation for presentation and previews.
class SampleMemorial {
  final String id;
  final String fullName;
  final String relationship;
  final String category; // 'parents', 'grandparents', 'relatives'
  final String birthYear;
  final String passingYear;
  final int age;
  final String restingPlace;
  final String? photoUrl;

  const SampleMemorial({
    required this.id,
    required this.fullName,
    required this.relationship,
    required this.category,
    required this.birthYear,
    required this.passingYear,
    required this.age,
    required this.restingPlace,
    this.photoUrl,
  });

  static const List<SampleMemorial> defaultList = [
    SampleMemorial(
      id: '1',
      fullName: 'Haji Abdul Gafur',
      relationship: 'Paternal Grandfather (দাদা)',
      category: 'grandparents',
      birthYear: '1935',
      passingYear: '2016',
      age: 81,
      restingPlace: 'Azimpur Graveyard, Plot 14, Dhaka',
    ),
    SampleMemorial(
      id: '2',
      fullName: 'Begum Rokeya Khatun',
      relationship: 'Paternal Grandmother (দাদী)',
      category: 'grandparents',
      birthYear: '1942',
      passingYear: '2020',
      age: 78,
      restingPlace: 'Azimpur Graveyard, Plot 15, Dhaka',
    ),
    SampleMemorial(
      id: '3',
      fullName: 'Muhammad Shamsul Huda',
      relationship: 'Father (বাবা)',
      category: 'parents',
      birthYear: '1961',
      passingYear: '2023',
      age: 62,
      restingPlace: 'Banani Cemetery, Section B, Dhaka',
    ),
    SampleMemorial(
      id: '4',
      fullName: 'Nurul Islam Chowdhury',
      relationship: 'Maternal Uncle (মামা)',
      category: 'relatives',
      birthYear: '1955',
      passingYear: '2019',
      age: 64,
      restingPlace: 'Garibullah Shah Mazar Cemetery, Chittagong',
    ),
  ];
}
