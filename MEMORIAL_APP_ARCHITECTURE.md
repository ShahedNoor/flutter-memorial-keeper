# Memorial Keeper: Family Tree — Complete Technical Specification & Architecture

## 1. Executive Summary & Vision

**Memorial Keeper: Family Tree** is a high-performance, real-time memorial and family genealogy application built with **Flutter**, fully powered by the **Firebase Ecosystem** (**Firebase Authentication**, **Cloud Firestore**, and **Firebase Cloud Storage**).

The application provides instant data synchronization, automatic offline caching, sub-100ms response times, and enterprise-grade security for preserving cherished family memories, resting places, genealogical relationships, and photo archives across generations.

### Key Architectural Strengths
- **Instant Real-Time Sync & Low Latency:** Powered by Firestore reactive listeners (`StreamBuilder`), updates across family devices reflect in under 100ms.
- **Automatic Offline Caching:** Relatives can view names, biographies, photos, and resting place locations without internet access (e.g. while visiting remote cemeteries).
- **Secure Authentication:** Integrated with Firebase Auth supporting Email/Password, Google Sign-In, and Apple Sign-In with fine-grained Firebase Security Rules.
- **Direct Cloud Storage:** High-resolution photos are uploaded directly to Firebase Storage with secure CDN delivery and automatic caching via `cached_network_image`.
- **Generous Free Tier (Firebase Spark Plan):** 50,000 reads/day, 20,000 writes/day, and 1 GB cloud storage with $0 hosting fees for standard usage.

---

## 2. System Architecture Diagram

```
+-----------------------------------------------------------------------------------+
|                                  FLUTTER CLIENT                                   |
|  - UI Layer (Riverpod / BLoC / Provider + FlutterFire)                            |
|  - Offline Persistence (Firestore Local Cache & CachedNetworkImage)               |
+-----------------------------------------+-----------------------------------------+
                                          |
          +-------------------------------+-------------------------------+
          | (Auth Tokens)                 | (Real-time Streams / CRUD)    | (Direct Image Upload)
          v                               v                               v
+-------------------+           +-------------------+           +-------------------+
|   FIREBASE AUTH   |           |  CLOUD FIRESTORE  |           | FIREBASE STORAGE  |
|  - Email/Password |           |  - memorial_users |           |  - memorial_photos|
|  - Google Sign-In |           |  - family_members |           |    /{uid}/{id}.jpg|
|  - Apple Sign-In  |           |  - tributes/notes |           |                   |
+-------------------+           +-------------------+           +-------------------+
          |                               |                               |
          +-------------------------------+-------------------------------+
                                          |
                                          v
                    +-------------------------------------------+
                    |          FIREBASE SECURITY RULES          |
                    |  - Role-based authorization               |
                    |  - Data validation & file size limits     |
                    +-------------------------------------------+
```

---

## 3. Firestore Database Schema

Firestore stores JSON-like documents organized into structured collections.

### Collection 1: `memorial_entries`
Stores records of deceased family members, relatives, and close friends.

| Field Name | Type | Example Value | Description |
| :--- | :--- | :--- | :--- |
| `id` | `String` (Doc ID) | `mem_8f92a10b` | Auto-generated document ID |
| `category` | `String` | `"family"` or `"friends"` | Category selector for UI tabs |
| `fullName` | `String` | `"John Robert Smith"` | Full legal or known name |
| `relationship` | `String` | `"Maternal Grandfather"` | Relationship descriptor |
| `dateOfBirth` | `Timestamp` / `String` | `"1938-04-12"` | Birth date |
| `dateOfPassing` | `Timestamp` / `String` | `"2015-11-03"` | Passing date |
| `age` | `int` | `77` | Calculated age at passing |
| `location` | `String` | `"Oakridge Cemetery, Plot B-14"` | Resting place or city name |
| `geoPoint` | `GeoPoint` *(Optional)* | `GeoPoint(41.8781, -87.6298)` | Exact GPS coordinates for cemetery map |
| `photoUrl` | `String` | `"https://firebasestorage.googleapis.com/..."` | Direct Firebase Storage download URL |
| `notes` | `String` | `"Loved gardening; served 1958–1962"` | Biographies, stories, lifetime achievements |
| `createdBy` | `String` | `"firebase_uid_12345"` | Creator UID |
| `createdAt` | `Timestamp` | `FieldValue.serverTimestamp()` | Record creation timestamp |
| `updatedAt` | `Timestamp` | `FieldValue.serverTimestamp()` | Last updated timestamp |

---

### Collection 2: `users`
Stores user profiles and authorization roles.

| Field Name | Type | Example Value | Description |
| :--- | :--- | :--- | :--- |
| `uid` | `String` (Doc ID) | `"firebase_uid_12345"` | Firebase Auth UID |
| `email` | `String` | `"admin@example.com"` | User email address |
| `displayName` | `String` | `"Noor Smith"` | User display name |
| `role` | `String` | `"admin"` / `"editor"` / `"viewer"` | Access permission level |
| `createdAt` | `Timestamp` | `FieldValue.serverTimestamp()` | Account registration date |

---

### Collection 3: `tributes` *(Optional Subcollection: `memorial_entries/{id}/tributes`)*
Allows family members to leave prayers, memories, or condolences.

| Field Name | Type | Example Value | Description |
| :--- | :--- | :--- | :--- |
| `id` | `String` (Doc ID) | `trib_1102a` | Tribute ID |
| `authorUid` | `String` | `"firebase_uid_12345"` | Author UID |
| `authorName` | `String` | `"Aunt Sarah"` | Author display name |
| `message` | `String` | `"Always remembered in our daily prayers."` | Prayer or tribute message |
| `createdAt` | `Timestamp` | `FieldValue.serverTimestamp()` | Timestamp |

---

## 4. Firebase Storage & Media Pipeline

### Storage Folder Hierarchy
```
memorial_photos/
  └── {userId}/
        └── {entryId}_{timestamp}.jpg
```

### Media Pipeline Workflow
1. **Picker & Compression:** Flutter captures or selects photo using `image_picker` and compresses it using `flutter_image_compress` to ~300 KB–600 KB.
2. **Direct Upload:** Uploaded to `FirebaseStorage.instance.ref('memorial_photos/...').putFile(file)`.
3. **URL Generation:** Flutter retrieves the permanent `downloadURL` and saves it into the Firestore document.
4. **Caching & Display:** Rendered using `CachedNetworkImage` with disk caching and smooth shimmer placeholders.

---

## 5. Firebase Security Rules

### Firestore Security Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Memorial entries: Public read for family, authenticated write
    match /memorial_entries/{entryId} {
      allow read: if true; // Or restrict to isAuthenticated() for private family space
      allow create: if isAuthenticated() && request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if isAuthenticated() && (
        resource.data.createdBy == request.auth.uid ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin"
      );

      // Nested tributes subcollection
      match /tributes/{tributeId} {
        allow read: if true;
        allow create: if isAuthenticated();
        allow update, delete: if isAuthenticated() && resource.data.authorUid == request.auth.uid;
      }
    }

    // User profiles
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
  }
}
```

### Firebase Storage Security Rules (`storage.rules`)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /memorial_photos/{userId}/{fileName} {
      // Anyone can view photos
      allow read: if true;
      // Only authenticated users can upload photos (< 5MB and image types only)
      allow write: if request.auth != null && 
                   request.auth.uid == userId &&
                   request.resource.size < 5 * 1024 * 1024 &&
                   request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## 6. Flutter Implementation Guide

### Dependencies (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.10.0
  firebase_auth: ^5.4.0
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0
  google_sign_in: ^6.2.2
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  flutter_image_compress: ^2.3.0
  intl: ^0.19.0
```

---

### Data Model (`memorial_entry.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MemorialEntry {
  final String id;
  final String category; // 'family' or 'friends'
  final String fullName;
  final String relationship;
  final String dateOfBirth;
  final String dateOfPassing;
  final int age;
  final String location;
  final GeoPoint? geoPoint;
  final String photoUrl;
  final String notes;
  final String createdBy;
  final DateTime? createdAt;

  MemorialEntry({
    required this.id,
    required this.category,
    required this.fullName,
    required this.relationship,
    required this.dateOfBirth,
    required this.dateOfPassing,
    required this.age,
    required this.location,
    this.geoPoint,
    required this.photoUrl,
    required this.notes,
    required this.createdBy,
    this.createdAt,
  });

  factory MemorialEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemorialEntry(
      id: doc.id,
      category: data['category'] ?? 'family',
      fullName: data['fullName'] ?? '',
      relationship: data['relationship'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      dateOfPassing: data['dateOfPassing'] ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      location: data['location'] ?? '',
      geoPoint: data['geoPoint'] as GeoPoint?,
      photoUrl: data['photoUrl'] ?? '',
      notes: data['notes'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'fullName': fullName,
      'relationship': relationship,
      'dateOfBirth': dateOfBirth,
      'dateOfPassing': dateOfPassing,
      'age': age,
      'location': location,
      if (geoPoint != null) 'geoPoint': geoPoint,
      'photoUrl': photoUrl,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
```

---

### Memorial Repository Service (`memorial_service.dart`)
```dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'memorial_entry.dart';

class MemorialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _entriesRef => _firestore.collection('memorial_entries');

  /// Real-time stream of memorial entries filtered by category (family / friends)
  Stream<List<MemorialEntry>> getEntriesStream({required String category}) {
    return _entriesRef
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MemorialEntry.fromFirestore(doc)).toList());
  }

  /// Upload photo to Firebase Cloud Storage and return public download URL
  Future<String> uploadPhoto(File imageFile, String entryId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User must be logged in to upload photos.");

    final fileName = '${entryId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('memorial_photos').child(user.uid).child(fileName);

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  /// Create new memorial record
  Future<void> createEntry({
    required String category,
    required String fullName,
    required String relationship,
    required String dateOfBirth,
    required String dateOfPassing,
    required int age,
    required String location,
    GeoPoint? geoPoint,
    required String notes,
    File? imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User must be logged in.");

    final docRef = _entriesRef.doc();
    String photoUrl = '';

    if (imageFile != null) {
      photoUrl = await uploadPhoto(imageFile, docRef.id);
    }

    final entry = MemorialEntry(
      id: docRef.id,
      category: category,
      fullName: fullName,
      relationship: relationship,
      dateOfBirth: dateOfBirth,
      dateOfPassing: dateOfPassing,
      age: age,
      location: location,
      geoPoint: geoPoint,
      photoUrl: photoUrl,
      notes: notes,
      createdBy: user.uid,
    );

    await docRef.set(entry.toFirestore());
  }

  /// Update existing memorial record
  Future<void> updateEntry({
    required MemorialEntry existingEntry,
    File? newImageFile,
  }) async {
    String photoUrl = existingEntry.photoUrl;

    if (newImageFile != null) {
      photoUrl = await uploadPhoto(newImageFile, existingEntry.id);
    }

    final updatedData = existingEntry.toFirestore();
    updatedData['photoUrl'] = photoUrl;

    await _entriesRef.doc(existingEntry.id).update(updatedData);
  }

  /// Delete memorial record & associated photo
  Future<void> deleteEntry(MemorialEntry entry) async {
    await _entriesRef.doc(entry.id).delete();
    if (entry.photoUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(entry.photoUrl).delete();
      } catch (_) {
        // Photo deletion failure is non-blocking
      }
    }
  }
}
```

---

## 7. Free Tier Quotas & Scaling Strategy

| Firebase Product | Spark Plan (100% Free Tier) | Scaling / Optimization Practice |
| :--- | :--- | :--- |
| **Firebase Auth** | **Unlimited** Email/Password & Google Sign-In | Free indefinitely. |
| **Cloud Firestore Reads** | **50,000 document reads / day** | Firestore offline caching stores documents locally; queries only fetch delta changes. |
| **Cloud Firestore Writes** | **20,000 document writes / day** | Family memorials are low-write, read-heavy databases. |
| **Firebase Storage** | **1 GB stored assets** (~2,500 compressed photos) | Images compressed to ~400 KB before upload via `flutter_image_compress`. |
| **Network Egress (Bandwidth)** | **10 GB download / month** | `CachedNetworkImage` caches photos on the user's phone, avoiding repeated downloads. |

---

## 8. Store Policies, Review Guidelines & Platform Restrictions

When publishing **Memorial Keeper: Family Tree** to Apple App Store and Google Play Store:

### 1. User-Generated Content (UGC) Requirements (Apple 1.2 & Google Play Policy)
- **Report & Flagging:** Provide an in-app "Report Inappropriate Entry" action on profile views.
- **Terms of Service (EULA):** Include explicit terms prohibiting harassment, defamation, or inappropriate imagery.

### 2. Privacy Policy & Data Safety (Apple 5.1 & Google Data Safety)
- Declare data collection for:
  - **Photos/Videos:** Uploaded by the user for memorial profiles.
  - **User IDs / Email:** Used exclusively for account authentication and record ownership.

### 3. Account Deletion Requirement (Apple 5.1.1(v) & Google Play 2023+ Policy)
- Provide a clear **"Delete Account"** button in user settings that calls `FirebaseAuth.instance.currentUser?.delete()` and removes their user document from Firestore.

---

## 9. App Naming, ASO & Marketing Strategy

### Official Selected App Name & Store Metadata (SEO & ASO Focused)

To maximize organic search discoverability across Google Play, Apple App Store, and search engines:

- **App Display Name:** `Memorial Keeper`
- **Store Full Title (30 chars max):** `Memorial Keeper: Family Tree`
- **Subtitle / Short Description (80 chars max):** `Preserve family tree, resting places, photos & memories of departed loved ones.`
- **Target ASO Keywords (Metadata Bank):**
  ```
  memorial, family tree, memorial keeper, genealogy, tribute, remembrance, 
  deceased, obituary, ancestry, resting place, cemetery locator, family lineage
  ```

---

### Alternative & Marketing Branding Bank (Islamic & Cultural Campaigns)

For targeted marketing, community outreach, and cultural/faith-based branding, the following names are reserved:

#### 🌟 Primary Marketing Brand: **Zikra (ذكرى)**
- **Meaning:** *"Remembrance" / "Cherished Memory"* — Quranic concept of remembering those who came before.
- **Campaign Tagline:** *Keep their memory alive in prayer and love.*
- **Use Case:** Social media campaigns, community landing pages, and localized Islamic editions (`Zikra by Memorial Keeper`).

#### Supplementary Marketing & Theme Concepts

| Name | Arabic Script | Meaning & Concept | Campaign Focus |
| :--- | :--- | :--- | :--- |
| **Silah** | صلة | *"Kinship / Family Bonds"* (*Silat ar-Rahim*) | Family tree & lineage preservation |
| **Nasab** | نسب | *"Lineage & Heritage"* | Traditional genealogical records & roots |
| **Athar** | أثر | *"Legacy & Footprints"* | Biographies, lifetime achievements & stories |
| **Rawdah** | روضة | *"Garden of Serenity"* | Memorial resting places & cemetery locations |
| **Marhoom** | مرحوم | *"Under God's Mercy"* | Remembering departed relatives with Dua |
