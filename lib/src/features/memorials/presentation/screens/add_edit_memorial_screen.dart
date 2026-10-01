import 'package:uuid/uuid.dart';
import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';
import '../../domain/entities/memorial.dart';
import '../providers/memorial_bloc.dart';
import '../widgets/widgets.dart';

/// Screen for creating or updating a Memorial record.
class AddEditMemorialScreen extends StatefulWidget {
  const AddEditMemorialScreen({
    super.key,
    this.existingMemorial,
  });

  final Memorial? existingMemorial;

  @override
  State<AddEditMemorialScreen> createState() => _AddEditMemorialScreenState();
}

class _AddEditMemorialScreenState extends State<AddEditMemorialScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _arabicNameController;
  late TextEditingController _customRelationController;
  late TextEditingController _birthYearController;
  late TextEditingController _passingYearController;
  late TextEditingController _ageController;
  late TextEditingController _cemeteryNameController;
  late TextEditingController _cemeteryAreaController;
  late TextEditingController _gravePlotController;
  late TextEditingController _notesController;

  String _gender = 'male';
  String _category = 'family';
  String _relationship = 'father';
  bool _isYearOnly = true;

  DateTime? _dateOfBirth;
  DateTime? _dateOfDeath;

  String? _profilePhotoPath;
  String? _gravePhotoPath;

  bool get _isEditing => widget.existingMemorial != null;

  static const List<RelationshipOption> _familyRelationships = [
    (key: 'father', label: 'Father'),
    (key: 'mother', label: 'Mother'),
    (key: 'grandfather_paternal', label: 'Grandfather (Paternal)'),
    (key: 'grandmother_paternal', label: 'Grandmother (Paternal)'),
    (key: 'grandfather_maternal', label: 'Grandfather (Maternal)'),
    (key: 'grandmother_maternal', label: 'Grandmother (Maternal)'),
    (key: 'spouse', label: 'Spouse'),
    (key: 'brother', label: 'Brother'),
    (key: 'sister', label: 'Sister'),
    (key: 'son', label: 'Son'),
    (key: 'daughter', label: 'Daughter'),
    (key: 'uncle', label: 'Uncle'),
    (key: 'aunt', label: 'Aunt'),
  ];

  static const List<RelationshipOption> _othersRelationships = [
    (key: 'friends', label: 'Friend'),
    (key: 'teachers', label: 'Mentor / Teacher'),
    (key: 'elders', label: 'Elder / Community Leader'),
    (key: 'neighbors', label: 'Neighbor'),
    (key: 'colleagues', label: 'Colleague'),
    (key: 'other', label: 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.existingMemorial;

    _nameController = TextEditingController(text: m?.fullName ?? '');
    _arabicNameController = TextEditingController(text: m?.arabicName ?? '');
    _customRelationController =
        TextEditingController(text: m?.customRelation ?? '');
    _birthYearController =
        TextEditingController(text: m?.birthYear?.toString() ?? '');
    _passingYearController =
        TextEditingController(text: m?.passingYear?.toString() ?? '');
    _ageController = TextEditingController(text: m?.age?.toString() ?? '');
    _cemeteryNameController =
        TextEditingController(text: m?.cemeteryName ?? '');
    _cemeteryAreaController =
        TextEditingController(text: m?.cemeteryArea ?? '');
    _gravePlotController = TextEditingController(text: m?.gravePlot ?? '');
    _notesController = TextEditingController(text: m?.notesOrDua ?? '');

    if (m != null) {
      _gender = m.gender;
      _category = m.category;
      _relationship = m.relationship;
      _dateOfBirth = m.dateOfBirth;
      _dateOfDeath = m.dateOfDeath;
      _profilePhotoPath = m.profilePhotoPath;
      _gravePhotoPath = m.gravePhotoPath;
      _isYearOnly = m.dateOfBirth == null && m.dateOfDeath == null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arabicNameController.dispose();
    _customRelationController.dispose();
    _birthYearController.dispose();
    _passingYearController.dispose();
    _ageController.dispose();
    _cemeteryNameController.dispose();
    _cemeteryAreaController.dispose();
    _gravePlotController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateAge() {
    if (!_isYearOnly) {
      if (_dateOfBirth != null && _dateOfDeath != null) {
        int calculated = _dateOfDeath!.year - _dateOfBirth!.year;
        if (_dateOfDeath!.month < _dateOfBirth!.month ||
            (_dateOfDeath!.month == _dateOfBirth!.month &&
                _dateOfDeath!.day < _dateOfBirth!.day)) {
          calculated--;
        }
        if (calculated >= 0) {
          _ageController.text = calculated.toString();
        }
      }
    }
  }

  Future<void> _pickImage({required bool isGravePhoto}) async {
    final picker = ImagePicker();
    final hasExistingPhoto =
        isGravePhoto ? _gravePhotoPath != null : _profilePhotoPath != null;

    final action = await showPhotoPickerSheet(
      context,
      isGravePhoto: isGravePhoto,
      hasExistingPhoto: hasExistingPhoto,
    );

    if (action == 'remove') {
      setState(() {
        if (isGravePhoto) {
          _gravePhotoPath = null;
        } else {
          _profilePhotoPath = null;
        }
      });
      return;
    }

    if (action == 'camera' || action == 'gallery') {
      final source =
          action == 'camera' ? ImageSource.camera : ImageSource.gallery;
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          if (isGravePhoto) {
            _gravePhotoPath = picked.path;
          } else {
            _profilePhotoPath = picked.path;
          }
        });
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final id = widget.existingMemorial?.id ?? const Uuid().v4();

    int? bYear = int.tryParse(_birthYearController.text);
    int? pYear = int.tryParse(_passingYearController.text);
    int? ageVal;

    if (!_isYearOnly) {
      if (_dateOfBirth != null) bYear = _dateOfBirth!.year;
      if (_dateOfDeath != null) pYear = _dateOfDeath!.year;
      ageVal = int.tryParse(_ageController.text);
    } else {
      if (bYear != null && pYear != null && pYear >= bYear) {
        ageVal = pYear - bYear;
      }
    }

    final memorial = Memorial(
      id: id,
      fullName: _nameController.text.trim(),
      arabicName: _arabicNameController.text.trim().isEmpty
          ? null
          : _arabicNameController.text.trim(),
      gender: _gender,
      category: _category,
      relationship: _relationship,
      customRelation: _customRelationController.text.trim().isEmpty
          ? null
          : _customRelationController.text.trim(),
      dateOfBirth: _isYearOnly ? null : _dateOfBirth,
      birthYear: bYear,
      dateOfDeath: _isYearOnly ? null : _dateOfDeath,
      passingYear: pYear,
      age: ageVal,
      cemeteryName: _cemeteryNameController.text.trim().isEmpty
          ? null
          : _cemeteryNameController.text.trim(),
      cemeteryArea: _cemeteryAreaController.text.trim().isEmpty
          ? null
          : _cemeteryAreaController.text.trim(),
      gravePlot: _gravePlotController.text.trim().isEmpty
          ? null
          : _gravePlotController.text.trim(),
      profilePhotoPath: _profilePhotoPath,
      gravePhotoPath: _gravePhotoPath,
      notesOrDua: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isFavorite: widget.existingMemorial?.isFavorite ?? false,
      syncStatus:
          widget.existingMemorial != null ? 'pending_update' : 'pending_create',
      createdAt: widget.existingMemorial?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      context.read<MemorialBloc>().add(UpdateMemorialEvent(memorial));
    } else {
      context.read<MemorialBloc>().add(AddMemorialEvent(memorial));
    }

    showGlobalToast(
      message: _isEditing ? 'Record updated' : 'Record added successfully',
      status: 'success',
    );

    Navigator.of(context).pop();
  }

  Future<void> _onDelete() async {
    final confirmed = await showDeleteMemorialSheet(
      context,
      fullName: widget.existingMemorial!.fullName,
    );

    if (confirmed && mounted) {
      context
          .read<MemorialBloc>()
          .add(DeleteMemorialEvent(widget.existingMemorial!.id));
      showGlobalToast(
        message: 'Deleted record for ${widget.existingMemorial!.fullName}',
        status: 'info',
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final currentList =
        _category == 'family' ? _familyRelationships : _othersRelationships;
    final selectedRelationItem = currentList.firstWhere(
      (r) => r.key == _relationship,
      orElse: () => currentList.first,
    );

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Memorial Record' : 'Add Departed Loved One',
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: AppIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: cs.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: AppIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: cs.error,
              ),
              onPressed: _onDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          children: [
            // 1. Profile Avatar Picker
            MemorialAvatarPicker(
              photoPath: _profilePhotoPath,
              gender: _gender,
              onTap: () => _pickImage(isGravePhoto: false),
            ),
            SizedBox(height: 24.h),

            // 2. Gender Segmented Selector
            Text(
              'Gender',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceChip(
                    label: 'Male',
                    isSelected: _gender == 'male',
                    onTap: () => setState(() => _gender = 'male'),
                    cs: cs,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildChoiceChip(
                    label: 'Female',
                    isSelected: _gender == 'female',
                    onTap: () => setState(() => _gender = 'female'),
                    cs: cs,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // 3. Name Fields
            Text(
              'Full Name',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                hint: 'e.g. Haji Abdul Gafur',
                prefixIcon: HugeIcons.strokeRoundedUser,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            Text(
              'Alternative Name (Optional)',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _arabicNameController,
              decoration: _inputDecoration(
                hint: 'e.g. Nickname, Maiden Name, or Arabic name',
                prefixIcon: HugeIcons.strokeRoundedEdit02,
              ),
            ),
            SizedBox(height: 24.h),

            // 4. Category & Relationship
            Text(
              'Category',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceChip(
                    label: 'Family',
                    isSelected: _category == 'family',
                    onTap: () {
                      setState(() {
                        _category = 'family';
                        _relationship = 'father';
                      });
                    },
                    cs: cs,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildChoiceChip(
                    label: 'Others & Friends',
                    isSelected: _category == 'others',
                    onTap: () {
                      setState(() {
                        _category = 'others';
                        _relationship = 'friends';
                      });
                    },
                    cs: cs,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            Text(
              'Relationship',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            InkWell(
              onTap: () async {
                final selected = await showRelationshipPickerSheet(
                  context,
                  currentRelationship: _relationship,
                  relationships: currentList,
                );
                if (selected != null) {
                  setState(() => _relationship = selected);
                }
              },
              borderRadius: BorderRadius.circular(14.r),
              child: InputDecorator(
                decoration: _inputDecoration(
                  hint: 'Select relationship',
                  prefixIcon: HugeIcons.strokeRoundedUserGroup,
                ).copyWith(
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 14.w),
                    child: AppIcon(
                      icon: HugeIcons.strokeRoundedArrowDown01,
                      size: 18.sp,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                child: Text(
                  selectedRelationItem.label,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            TextFormField(
              controller: _customRelationController,
              decoration: _inputDecoration(
                hint: _category == 'family'
                    ? 'Optional custom title (e.g. Eldest Paternal Uncle)'
                    : 'Optional custom title (e.g. High School Mentor)',
                prefixIcon: HugeIcons.strokeRoundedBookmark01,
              ),
            ),
            SizedBox(height: 24.h),

            // 5. Lifespan & Dates Section (Separated component)
            LifespanDatesSection(
              isYearOnly: _isYearOnly,
              birthYearController: _birthYearController,
              passingYearController: _passingYearController,
              ageController: _ageController,
              dateOfBirth: _dateOfBirth,
              dateOfDeath: _dateOfDeath,
              onToggleYearOnly: (val) => setState(() => _isYearOnly = val),
              onYearChanged: _calculateAge,
              onPickBirthDate: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dateOfBirth ?? DateTime(1950),
                  firstDate: DateTime(1800),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _dateOfBirth = picked;
                    _birthYearController.text = picked.year.toString();
                  });
                  _calculateAge();
                }
              },
              onPickDeathDate: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dateOfDeath ?? DateTime.now(),
                  firstDate: DateTime(1800),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _dateOfDeath = picked;
                    _passingYearController.text = picked.year.toString();
                  });
                  _calculateAge();
                }
              },
              inputDecoration: ({required String hint, dynamic prefixIcon}) =>
                  _inputDecoration(hint: hint, prefixIcon: prefixIcon),
            ),
            SizedBox(height: 24.h),

            // 6. Resting Place & Cemetery Section (Separated component)
            RestingPlaceSection(
              cemeteryNameController: _cemeteryNameController,
              cemeteryAreaController: _cemeteryAreaController,
              gravePlotController: _gravePlotController,
              gravePhotoPath: _gravePhotoPath,
              onTapGravePhoto: () => _pickImage(isGravePhoto: true),
              inputDecoration: ({required String hint, dynamic prefixIcon}) =>
                  _inputDecoration(hint: hint, prefixIcon: prefixIcon),
            ),
            SizedBox(height: 24.h),

            // 7. Special Notes / Dua / Epitaph
            Text(
              'Memory Note / Special Dua',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: _inputDecoration(
                hint:
                    'e.g. May Allah grant him highest ranks in Jannah. Remembered for his generosity.',
              ),
            ),
            SizedBox(height: 32.h),

            // 8. Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 2,
              ),
              onPressed: _save,
              child: Text(
                _isEditing ? 'Save Changes' : 'Preserve Memorial Record',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : cs.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    dynamic prefixIcon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13.sp,
        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: EdgeInsets.only(left: 14.w, right: 10.w),
              child: AppIcon(
                icon: prefixIcon,
                size: 20.sp,
                color: cs.onSurfaceVariant,
              ),
            )
          : null,
      prefixIconConstraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
      filled: true,
      fillColor: cs.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
    );
  }
}
