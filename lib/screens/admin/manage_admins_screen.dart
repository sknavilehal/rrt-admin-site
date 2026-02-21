import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../models/admin.dart';
import '../../services/api_service.dart';

/// List of valid districts that can be assigned to admins
const List<String> validDistricts = [
  'adilabad', 'agra', 'ahmadabad', 'ahmadnagar', 'aizawl', 'ajmer', 'akola', 'alappuzha', 'aligarh', 'alirajpur',
  'allahabad', 'almora', 'alwar', 'ambala', 'ambedkar-nagar', 'amravati', 'amreli', 'amritsar', 'anand', 'anantapur',
  'anantnag', 'anjaw', 'anugul', 'anuppur', 'araria', 'ariyalur', 'arwal', 'ashoknagar', 'auraiya', 'aurangabad',
  'azamgarh', 'badgam', 'bagalkot', 'bageshwar', 'baghpat', 'bahraich', 'baksa', 'balaghat', 'balangir', 'baleshwar',
  'ballia', 'balrampur', 'banas-kantha', 'banda', 'bandipore', 'bangalore', 'bangalore-rural', 'banka', 'bankura',
  'banswara', 'bara-banki', 'baramula', 'baran', 'barddhaman', 'bareilly', 'bargarh', 'barmer', 'barnala', 'barpeta',
  'barwani', 'bastar', 'basti', 'bathinda', 'bauda', 'begusarai', 'belgaum', 'bellary', 'betul', 'bhadrak',
  'bhagalpur', 'bhandara', 'bharatpur', 'bharuch', 'bhavnagar', 'bhilwara', 'bhind', 'bhiwani', 'bhojpur', 'bhopal',
  'bid', 'bidar', 'bijapur', 'bijnor', 'bikaner', 'bilaspur', 'birbhum', 'bishnupur', 'bokaro', 'bongaigaon',
  'budaun', 'bulandshahr', 'buldana', 'bundi', 'burhanpur', 'buxar', 'cachar', 'central', 'chamba', 'chamoli',
  'champawat', 'champhai', 'chamrajnagar', 'chandauli', 'chandel', 'chandigarh', 'chandrapur', 'changlang', 'chatra',
  'chennai', 'chhatarpur', 'chhindwara', 'chikkaballapura', 'chikmagalur', 'chirang', 'chitradurga', 'chitrakoot',
  'chittaurgarh', 'chittoor', 'churachandpur', 'churu', 'coimbatore', 'cuddalore', 'cuttack', 'dadra--nagar-haveli',
  'dakshin-bastar-dantewada', 'dakshin-dinajpur', 'dakshina-kannada', 'daman', 'damoh', 'darbhanga', 'darjiling',
  'darrang', 'data-not-available', 'datia', 'dausa', 'davanagere', 'debagarh', 'dehradun', 'deoghar', 'deoria',
  'dewas', 'dhalai', 'dhamtari', 'dhanbad', 'dhar', 'dharmapuri', 'dharwad', 'dhaulpur', 'dhemaji', 'dhenkanal',
  'dhubri', 'dhule', 'dibang-valley', 'dibrugarh', 'dima-hasao', 'dimapur', 'dindigul', 'dindori', 'diu', 'doda',
  'dohad', 'dumka', 'dungarpur', 'durg', 'east', 'east-garo-hills', 'east-godavari', 'east-kameng', 'east-khasi-hills',
  'east-nimar', 'east-siang', 'ernakulam', 'erode', 'etah', 'etawah', 'faizabad', 'faridabad', 'faridkot',
  'farrukhabad', 'fatehabad', 'fatehgarh-sahib', 'fatehpur', 'firozabad', 'firozpur', 'gadag', 'gajapati',
  'ganderbal', 'gandhinagar', 'ganganagar', 'ganjam', 'garhchiroli', 'garhwa', 'garhwal', 'gautam-buddha-nagar',
  'gaya', 'ghaziabad', 'ghazipur', 'giridih', 'goalpara', 'godda', 'golaghat', 'gonda', 'gondiya', 'gopalganj',
  'gorakhpur', 'gulbarga', 'gumla', 'guna', 'guntur', 'gurdaspur', 'gurgaon', 'gwalior', 'hailakandi', 'hamirpur',
  'hanumangarh', 'haora', 'harda', 'hardoi', 'hardwar', 'hassan', 'haveri', 'hazaribagh', 'hingoli', 'hisar',
  'hoshangabad', 'hoshiarpur', 'hugli', 'hyderabad', 'idukki', 'imphal-east', 'imphal-west', 'indore', 'jabalpur',
  'jagatsinghapur', 'jaintia-hills', 'jaipur', 'jaisalmer', 'jajapur', 'jalandhar', 'jalaun', 'jalgaon', 'jalna',
  'jalor', 'jalpaiguri', 'jammu', 'jamnagar', 'jamtara', 'jamui', 'janjgir-champa', 'jashpur', 'jaunpur',
  'jehanabad', 'jhabua', 'jhajjar', 'jhalawar', 'jhansi', 'jharsuguda', 'jhunjhunun', 'jind', 'jodhpur', 'jorhat',
  'junagadh', 'jyotiba-phule-nagar', 'kabeerdham', 'kachchh', 'kaimur-bhabua', 'kaithal', 'kalahandi', 'kamrup',
  'kamrup-metropolitan', 'kancheepuram', 'kandhamal', 'kangra', 'kannauj', 'kanniyakumari', 'kannur', 'kanpur-dehat',
  'kanpur-nagar', 'kansiram-nagar', 'kapurthala', 'karaikal', 'karauli', 'karbi-anglong', 'kargil', 'karimganj',
  'karimnagar', 'karnal', 'karur', 'kasaragod', 'kathua', 'katihar', 'katni', 'kaushambi', 'kendrapara',
  'kendujhar', 'khagaria', 'khammam', 'kheda', 'kheri', 'khordha', 'khunti', 'kinnaur', 'kiphire', 'kishanganj',
  'kishtwar', 'koch-bihar', 'kodagu', 'kodarma', 'kohima', 'kokrajhar', 'kolar', 'kolasib', 'kolhapur', 'kolkata',
  'kollam', 'koppal', 'koraput', 'korba', 'koriya', 'kota', 'kottayam', 'kozhikode', 'krishna', 'krishnagiri',
  'kulgam', 'kullu', 'kupwara', 'kurnool', 'kurukshetra', 'kurung-kumey', 'kushinagar', 'lahul--spiti', 'lakhimpur',
  'lakhisarai', 'lakshadweep', 'lalitpur', 'latehar', 'latur', 'lawangtlai', 'leh-ladakh', 'lohardaga', 'lohit',
  'longleng', 'lower-dibang-valley', 'lower-subansiri', 'lucknow', 'ludhiana', 'lunglei', 'madhepura', 'madhubani',
  'madurai', 'mahamaya-nagar', 'maharajganj', 'mahasamund', 'mahbubnagar', 'mahe', 'mahendragarh', 'mahesana',
  'mahoba', 'mainpuri', 'malappuram', 'maldah', 'malkangiri', 'mamit', 'mandi', 'mandla', 'mandsaur', 'mandya',
  'mansa', 'marigaon', 'mathura', 'mau', 'mayurbhanj', 'medak', 'meerut', 'mewat', 'mirzapur', 'moga', 'mokokchung',
  'mon', 'moradabad', 'morena', 'muktsar', 'mumbai', 'mumbai-suburban', 'munger', 'murshidabad', 'muzaffarnagar',
  'muzaffarpur', 'mysore', 'nabarangapur', 'nadia', 'nagaon', 'nagappattinam', 'nagaur', 'nagpur', 'nainital',
  'nalanda', 'nalbari', 'nalgonda', 'namakkal', 'nanded', 'nandurbar', 'narayanpur', 'narmada', 'narsimhapur',
  'nashik', 'navsari', 'nawada', 'nayagarh', 'neemuch', 'new-delhi', 'nicobar', 'nizamabad', 'north',
  'north--middle-andaman', 'north-24-parganas', 'north-east', 'north-goa', 'north-tripura', 'north-west', 'nuapada',
  'osmanabad', 'pakur', 'palakkad', 'palamu', 'pali', 'palwal', 'panch-mahals', 'panchkula', 'panipat', 'panna',
  'papum-pare', 'parbhani', 'pashchim-champaran', 'pashchim-medinipur', 'pashchimi-singhbhum', 'patan',
  'pathanamthitta', 'patiala', 'patna', 'perambalur', 'peren', 'phek', 'pilibhit', 'pithoragarh', 'porbandar',
  'prakasam', 'pratapgarh', 'puducherry', 'pudukkottai', 'pulwama', 'punch', 'pune', 'purba-champaran',
  'purba-medinipur', 'purbi-singhbhum', 'puri', 'purnia', 'puruliya', 'rae-bareli', 'raichur', 'raigarh', 'raipur',
  'raisen', 'rajgarh', 'rajkot', 'rajnandgaon', 'rajouri', 'rajsamand', 'ramanagara', 'ramanathapuram', 'ramban',
  'ramgarh', 'rampur', 'ranchi', 'rangareddy', 'ratlam', 'ratnagiri', 'rayagada', 'reasi', 'rewa', 'rewari',
  'ri-bhoi', 'rohtak', 'rohtas', 'rudraprayag', 'rupnagar', 'sabar-kantha', 'sagar', 'saharanpur', 'saharsa',
  'sahibganj', 'sahibzada-ajit-singh-nagar', 'saiha', 'salem', 'samastipur', 'samba', 'sambalpur', 'sangli',
  'sangrur', 'sant-kabir-nagar', 'sant-ravi-das-nagarbhadohi', 'saraikela-kharsawan', 'saran-chhapra', 'satara',
  'satna', 'sawai-madhopur', 'sehore', 'senapati', 'seoni', 'serchhip', 'shahdol', 'shahid-bhagat-singh-nagar',
  'shahjahanpur', 'shajapur', 'sheikhpura', 'sheohar', 'sheopur', 'shimla', 'shimoga', 'shivpuri', 'shrawasti',
  'shupiyan', 'siddharth-nagar', 'sidhi', 'sikar', 'simdega', 'sindhudurg', 'singrauli', 'sirmaur', 'sirohi',
  'sirsa', 'sitamarhi', 'sitapur', 'sivaganga', 'sivasagar', 'siwan', 'solan', 'solapur', 'sonbhadra', 'sonipat',
  'sonitpur', 'south', 'south-24-parganas', 'south-andaman', 'south-garo-hills', 'south-goa', 'south-tripura',
  'south-west', 'sri-potti-sriramulu-nellore', 'srikakulam', 'srinagar', 'subarnapur', 'sultanpur', 'sundargarh',
  'supaul', 'surat', 'surendranagar', 'surguja', 'tamenglong', 'tapi', 'tarn-taran', 'tawang', 'tehri-garhwal',
  'thane', 'thanjavur', 'the-dangs', 'the-nilgiris', 'theni', 'thiruvallur', 'thiruvananthapuram', 'thiruvarur',
  'thoothukkudi', 'thoubal', 'thrissur', 'tikamgarh', 'tinsukia', 'tirap', 'tiruchirappalli', 'tirunelveli',
  'tiruppur', 'tiruvannamalai', 'tonk', 'tuensang', 'tumkur', 'udaipur', 'udalguri', 'udham-singh-nagar', 'udhampur',
  'udupi', 'ujjain', 'ukhrul', 'umaria', 'una', 'unnao', 'upper-siang', 'upper-subansiri', 'uttar-bastar-kanker',
  'uttar-dinajpur', 'uttara-kannada', 'uttarkashi', 'vadodara', 'vaishali', 'valsad', 'varanasi', 'vellore',
  'vidisha', 'viluppuram', 'virudunagar', 'visakhapatnam', 'vizianagaram', 'warangal', 'wardha', 'washim',
  'wayanad', 'west', 'west-garo-hills', 'west-godavari', 'west-kameng', 'west-khasi-hills', 'west-nimar',
  'west-siang', 'west-tripura', 'wokha', 'yadgir', 'yamunanagar', 'yanam', 'yavatmal', 'ysr', 'zunheboto',
];

/// Manage Admins screen (Super Admin only)
class ManageAdminsScreen extends StatefulWidget {
  final UserProfile userProfile;
  final ApiService apiService;

  const ManageAdminsScreen({
    super.key,
    required this.userProfile,
    required this.apiService,
  });

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  List<Admin> _admins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final admins = await widget.apiService.getAdmins();
      setState(() {
        _admins = admins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading admins: $e')),
        );
      }
    }
  }

  static String _generateTempPassword({int length = 12}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random.secure();
    return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<void> _showAddAdminDialog() async {
    final emailController = TextEditingController();
    final districtsController = TextEditingController();
    String? districtsError;
    List<String> suggestions = [];

    await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setDlgState) => AlertDialog(
          title: const Text('Add New Admin'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: districtsController,
                        decoration: InputDecoration(
                          labelText: 'Assigned Districts (comma-separated)',
                          hintText: 'e.g., bangalore, pune, mumbai',
                          border: const OutlineInputBorder(),
                          helperText: 'Type to see suggestions below. Separate multiple districts with commas.',
                          helperMaxLines: 2,
                          errorText: districtsError,
                        ),
                        onChanged: (value) {
                          setDlgState(() {
                            districtsError = null;
                            
                            // Get the current word being typed (after the last comma)
                            final currentInput = value.split(',').last.trim().toLowerCase();
                            
                            if (currentInput.length >= 2) {
                              // Show suggestions that contain the current input
                              suggestions = validDistricts
                                  .where((district) => district.toLowerCase().contains(currentInput))
                                  .take(10)
                                  .toList();
                            } else {
                              suggestions = [];
                            }
                          });
                        },
                      ),
                      if (suggestions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade50,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: suggestions.length,
                            itemBuilder: (_, index) {
                              final suggestion = suggestions[index];
                              return InkWell(
                                onTap: () {
                                  // Replace the last partial district with the selected one
                                  final parts = districtsController.text.split(',');
                                  parts[parts.length - 1] = ' $suggestion';
                                  districtsController.text = '${parts.join(',')}, ';
                                  
                                  setDlgState(() {
                                    suggestions = [];
                                    districtsError = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: index < suggestions.length - 1
                                            ? Colors.grey.shade300
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    suggestion,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter email')),
                  );
                  return;
                }

                // Parse and validate districts
                final districts = districtsController.text
                    .split(',')
                    .map((d) => d.trim().toLowerCase())
                    .where((d) => d.isNotEmpty)
                    .toList();
                
                // Validate all districts are in the valid list
                final invalidDistricts = districts
                    .where((d) => !validDistricts.contains(d))
                    .toList();
                
                if (invalidDistricts.isNotEmpty) {
                  setDlgState(() {
                    districtsError = 'Invalid districts: ${invalidDistricts.join(", ")}';
                  });
                  return;
                }

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                navigator.pop(true);

                final tempPassword = _generateTempPassword();
                try {
                  await widget.apiService.createAdmin(
                    email: emailController.text.trim(),
                    password: tempPassword,
                    assignedDistricts: districts,
                  );

                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                        content: Text('Admin created successfully. An email with the temporary password has been sent.')),
                  );
                  _loadAdmins();
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAdmin(Admin admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete ${admin.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.apiService.deleteAdmin(admin.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin deleted successfully')),
        );
        _loadAdmins();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 40),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_admins.isEmpty)
            _buildEmptyState()
          else
            _buildAdminsTable(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADMIN MANAGEMENT',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Manage Admins',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                height: 1.2,
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: _showAddAdminDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.add, size: 20),
              SizedBox(width: 8),
              Text(
                'ADD ADMIN',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No admins yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add an admin to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          _buildTableRows(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'EMAIL',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'ASSIGNED DISTRICTS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'STATUS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ACTIONS',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRows() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _admins.length,
      itemBuilder: (context, index) {
        final admin = _admins[index];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: index < _admins.length - 1
                    ? Colors.grey.shade200
                    : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      admin.email,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: admin.assignedDistricts
                      .map((district) => Chip(
                            label: Text(
                              district.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                            backgroundColor: Colors.grey.shade200,
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: admin.active
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    admin.active ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: admin.active
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => _deleteAdmin(admin),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Delete admin',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
