import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mad_ca3/book_appointment_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // for Clipboard

class VetPage extends StatefulWidget {
  @override
  _VetPageState createState() => _VetPageState();
}

class _VetPageState extends State<VetPage> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  late MapController _mapController = MapController();
  String _searchText = '';
  List<Map<String, dynamic>> _selectedVets = [];
  late TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedVet;

  final List<Map<String, dynamic>> vets = [
    {
      'name': 'Beecroft Animal Specialist & Emergency Hospital',
      'lat': 1.2736452533578924,
      'lng': 103.80274713292441,
      'address': '991E Alexandra Road, #01-27 S(119973)',
      'rating': 3.9,
      'tel': '69961812',
      'mapUrl': 'https://maps.app.goo.gl/dj3yNMyQxgw7LqMF6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Veterinary Emergency and Specialty - VES Hospital @ Whitley',
      'lat': 1.3257904385850565,
      'lng': 103.827112372365,
      'address': '232 Whitley Rd, Singapore 297824',
      'rating': 4,
      'tel': '62660232',
      'mapUrl': 'https://maps.app.goo.gl/Zb2RwQHA3QNXCrKF8',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'AAVC-Animal & Avian Veterinary Clinic',
      'lat': 1.4266237398174693,
      'lng': 103.82756267791116,
      'address': 'Yishun Street 71, #01-254 Blk 716, Singapore 760716',
      'rating': 3.9,
      'tel': '68539397',
      'mapUrl': 'https://maps.app.goo.gl/8m7USKeJh1mtJRj37',
      'open': '10:00',
      'close': '19:30',
      'tempClosed': false,
    },
    {
      'name': 'Acacia Vet & Surgery',
      'lat': 1.3642209950939717,
      'lng': 103.8490150092949,
      'address':
          '338 Ang Mo Kio Ave 1, #01-1671 Teck Ghee Court, Singapore 560338',
      'rating': 4.6,
      'tel': '64816889',
      'mapUrl': 'https://maps.app.goo.gl/tPWpbsAfyyqf9cWs6',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Advanced VetCare Veterinary Centre (Bedok)',
      'lat': 1.3337014896895565,
      'lng': 103.9487235017444,
      'address': '26 Jln Pari Burong, Singapore 488692',
      'rating': 4.2,
      'tel': '66361788',
      'mapUrl': 'https://maps.app.goo.gl/MNTg5FGTixo6XJzH6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Advanced VetCare Veterinary Centre (Balestier)',
      'lat': 1.3269770063248634,
      'lng': 103.84480004737395,
      'address': '564A Balestier Rd, Singapore 329880',
      'rating': 4.7,
      'tel': '65651788',
      'mapUrl': 'https://maps.app.goo.gl/9HBei5WbycnG9GnU7',
      'open': '09:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name':
          'Advanced Animal Rehabilitation - Pet Hydrotherapy & Physiotherapy in Singapore',
      'lat': 1.3336368037459199,
      'lng': 103.94840840980794,
      'address': '18 Jln Pari Burong, Singapore 488684',
      'rating': 5,
      'tel': '88913207',
      'mapUrl': 'https://maps.app.goo.gl/N8yeBpBacqhMELh16',
      'open': '09:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Allpets & Aqualife Clinic',
      'lat': 1.383651348375314,
      'lng': 103.87555764907563,
      'address': '24 Jalan Kelulut, Seletar Hills Estate, 809041',
      'rating': 4.2,
      'tel': '64813700',
      'mapUrl': 'https://maps.app.goo.gl/TzjDSt8X7UsUwGka8',
      'open': '09:30',
      'close': '19:30',
      'tempClosed': false,
    },
    {
      'name': 'Amber Cat Vet @ East Coast | Vet Clinic for Cats',
      'lat': 1.312732237307669,
      'lng': 103.92266227726967,
      'address': '48 Burnfoot Terrace, Singapore 459836',
      'rating': 5,
      'tel': '62455543',
      'mapUrl': 'https://maps.app.goo.gl/WxuxQ2he2NCPm1Xz8',
      'open': '09:30',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'The Animal Ark Veterinary Group',
      'lat': 1.3361305404683197,
      'lng': 103.78685189642887,
      'address': '11 Binjai Park, Singapore 589823',
      'rating': 'N.A.',
      'tel': '61006000',
      'mapUrl': 'https://maps.app.goo.gl/1nKVUsFNJGumuNSc7',
      'tempClosed': false,
    },
    {
      'name': 'AVH Animal Ark - Tampines',
      'lat': 1.346453987191198,
      'lng': 103.94455994833999,
      'address': '139 Tampines St. 11, #01-54, Singapore 521139',
      'rating': 4.4,
      'tel': '65871797',
      'mapUrl': 'https://maps.app.goo.gl/uAJS2Z6s7UYC2VFY7',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'AVH Animal Ark - Mandai',
      'lat': 1.4025319992793637,
      'lng': 103.8168870122929,
      'address': '5 Mandai Rd, Singapore 779391',
      'rating': 4.5,
      'tel': '64673287',
      'mapUrl': 'https://maps.app.goo.gl/RQvb5JyhfBhKyMXMA',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Animal Infirmary Pte Ltd',
      'lat': 1.3114496287318325,
      'lng': 103.86269106441776,
      'address': '112 Lavender St. #01-01, Singapore 338728',
      'rating': 4.4,
      'tel': '63582663',
      'mapUrl': 'https://maps.app.goo.gl/VRfDVwNPRVeTYzNJ8',
      'open': '09:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'VET@RV',
      'lat': 1.2915325070841766,
      'lng': 103.827486354577,
      'address': '78 Indus Rd, #01-487 Indus Garden, Singapore 161078',
      'rating': 3.7,
      'tel': '62710665',
      'mapUrl': 'https://maps.app.goo.gl/jfyJfdKBF54McfD57',
      'open': '13:30',
      'close': '22:30',
      'tempClosed': false,
    },
    {
      'name': 'Pet Space Central Vet Surgery',
      'lat': 1.3141004230203481,
      'lng': 103.8571228939527,
      'address': '482 Serangoon Rd, #01-01, Singapore 218149',
      'rating': 4,
      'tel': '62522623',
      'mapUrl': 'https://maps.app.goo.gl/NLfSjcLr4pvpq7Yv6',
      'open': '09:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Animal Wellness Centre Pte Ltd',
      'lat': 1.307275067462843,
      'lng': 103.78882682833435,
      'address':
          '1 Vista Exchange Green, #01-15 The Star Vista, Singapore 138617',
      'rating': 4.2,
      'tel': '66946383',
      'mapUrl': 'https://maps.app.goo.gl/oP9is7QcCia9VAdT9',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Animal Wellness Referral Centre (24 Hour Vet)',
      'lat': 1.312056967089629,
      'lng': 103.8421936976501,
      'address': '200 Bukit Timah Rd, Singapore 229862',
      'rating': 4.3,
      'tel': '65303530',
      'mapUrl': 'https://maps.app.goo.gl/cvsbBkwfjonA6HLr7',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Animal World Veterinary Clinic',
      'lat': 1.354898870384089,
      'lng': 103.87758646881464,
      'address': '16 Yio Chu Kang Rd, Singapore 545527',
      'rating': 4.4,
      'tel': '62860929',
      'mapUrl': 'https://maps.app.goo.gl/EF8g3SvCgCdCq5Us6',
      'open': '09:30',
      'close': '19:30',
      'tempClosed': false,
    },
    {
      'name': 'Apex Veterinary Clinic (River Valley)',
      'lat': 1.2976790020624915,
      'lng': 103.8276094337835,
      'address': '462 River Valley Rd, Singapore 248347',
      'rating': 4.8,
      'tel': '67673369',
      'mapUrl': 'https://maps.app.goo.gl/fR3ipwFqQkpSUj1s9',
      'open': '09:30',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Apex Veterinary Clinic (Punggol)',
      'lat': 1.418746802320456,
      'lng': 103.90094944024727,
      'address':
          '418 Northshore Dr, #02-13 Northshore Plaza II, Singapore 820418',
      'rating': 4.2,
      'tel': '65183233',
      'mapUrl': 'https://maps.app.goo.gl/PJkM1kVQPjCSJAoF7',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Atlas Veterinary Clinic & Surgery',
      'lat': 1.2839608738350266,
      'lng': 103.81709441114337,
      'address': '163 Bukit Merah Central, #03-3573, Singapore 150163',
      'rating': 5,
      'tel': '69808038',
      'mapUrl': 'https://maps.app.goo.gl/xHJNq9aMZFr3Xwco8',
      'open': '10:00',
      'close': '18:30',
      'tempClosed': false,
    },
    {
      'name': 'Barkway Pet Health',
      'lat': 1.3301227213428608,
      'lng': 103.87381530929477,
      'address': '169 MacPherson Rd, Sennett Estate, Singapore 348535',
      'rating': 4.7,
      'tel': '69044300',
      'mapUrl': 'https://maps.app.goo.gl/aQ354mQTu2XhungL9',
      'open': '09:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Bluewater Vet Acupuncture & Rehabilitation',
      'lat': 1.3530236121466646,
      'lng': 103.83635862278818,
      'address': '6 Sin Ming Road #01-09, Tower 2 Sin Ming Plaza, 575585',
      'rating': 4.9,
      'tel': '87753041',
      'mapUrl': 'https://maps.app.goo.gl/vGAqZVurRBjrqvQ9A',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Brighton Vet Care (Bukit Timah)',
      'lat': 1.324656621917426,
      'lng': 103.80947176696581,
      'address': '611 Bukit Timah Rd, Singapore 269712',
      'rating': 4.5,
      'tel': '62352250',
      'mapUrl': 'https://maps.app.goo.gl/sD3xkJPqDXoTd7ATA',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Brighton Vet Care (Katong)',
      'lat': 1.306926823764861,
      'lng': 103.90430411114342,
      'address': '438 Joo Chiat Rd, Singapore 427651',
      'rating': 4.3,
      'tel': '62149521',
      'mapUrl': 'https://maps.app.goo.gl/d3C8huP4ssnBPNoa9',
      'open': '10:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Brighton Vet Care (Serangoon Gardens)',
      'lat': 1.3672490247555331,
      'lng': 103.86528229120863,
      'address': '74 Serangoon Garden Way, Singapore 555970',
      'rating': 4.5,
      'tel': '62822484',
      'mapUrl': 'https://maps.app.goo.gl/8zzRwjZRzWtYsgmU6',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Care Veterinary Pte Ltd',
      'lat': 1.3424843963197393,
      'lng': 103.84360717493601,
      'address': 'Blk #01-473, 124 Lor 1 Toa Payoh, 310124',
      'rating': 4.4,
      'tel': '62500535',
      'mapUrl': 'https://maps.app.goo.gl/vZ7rAmSDUgeTDFrUA',
      'open': '09:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Clinic for Pets',
      'lat': 1.3193290852889783,
      'lng': 103.89126106255306,
      'address': '1015 Geylang East Ave 3, #01-141, Singapore 389730',
      'rating': 3.9,
      'tel': '67451337',
      'mapUrl': 'https://maps.app.goo.gl/UCFmaeJVotsQM6na8',
      'open': '09:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Companion Animal Surgery',
      'lat': 1.3262811523743527,
      'lng': 103.84965595347634,
      'address': '12 Boon Teck Rd, Singapore 329586',
      'rating': 4,
      'tel': '62557950',
      'mapUrl': 'https://maps.app.goo.gl/Q3BuvF4VAzqY1UkH7',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name':
          'Dr Paws Vet Care - Pets/Pocket Pets Health Checks, Vaccinations and Surgeries',
      'lat': 1.3184255731264507,
      'lng': 103.94149636171218,
      'address': '77 Lucky Heights Lucky Court (off, Upper E Coast Rd, 467626',
      'rating': 4.8,
      'tel': '62434668',
      'mapUrl': 'https://maps.app.goo.gl/FF3yzTwNSbiyes8y8',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Edmond Tan Veterinary Surgery',
      'lat': 1.369836265556639,
      'lng': 103.87396045162379,
      'address':
          '151 Serangoon North Ave. 2, #01-65 Serangoon North Village, Singapore 550151',
      'rating': 4.3,
      'tel': '62821581',
      'mapUrl': 'https://maps.app.goo.gl/wcjPmDuViiCGwtrJ8',
      'open': '10:00',
      'close': '12:00',
      'tempClosed': false,
    },
    {
      'name': 'EverVet Veterinary Clinic (Bedok)',
      'lat': 1.330341672671711,
      'lng': 103.93722595632805,
      'address': '123 Bedok North Street 2, #01-154, Singapore 460123',
      'rating': 4.4,
      'tel': '64494491',
      'mapUrl': 'https://maps.app.goo.gl/Bng9CAQtHxVj5tNE8',
      'open': '09:30',
      'close': '19:30',
      'tempClosed': false,
    },
    {
      'name': 'EverVet Veterinary Clinic (Eunos)',
      'lat': 1.318656619966922,
      'lng': 103.90353906545911,
      'address': '212 Changi Rd, Singapore 419735',
      'rating': 4.7,
      'tel': '65138138',
      'mapUrl': 'https://maps.app.goo.gl/VNQuqVDnxWMJQDGJ6',
      'open': '09:30',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Frankel Veterinary Centre',
      'lat': 1.3148159928856002,
      'lng': 103.91939849580139,
      'address': '101 Frankel Ave, Frankel Estate, Singapore 458224',
      'rating': 4.2,
      'tel': '68761212',
      'mapUrl': 'https://maps.app.goo.gl/watR3rgqs29fZzh8A',
      'open': '09:00',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'Furiends Veterinary Clinic',
      'lat': 1.3575795821275713,
      'lng': 103.87561055310793,
      'address': '58 Yio Chu Kang Rd, Singapore 545564',
      'rating': 4.7,
      'tel': '62442112',
      'mapUrl': 'https://maps.app.goo.gl/2dugm1cAPVqfjoeh7',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Furrytails Veterinary Clinic',
      'lat': 1.3459793420330426,
      'lng': 103.8826633227882,
      'address': 'Kensington Square, 2 Jln Lokam, #01-13/14, 537846',
      'rating': 4.7,
      'tel': '62149092',
      'mapUrl': 'https://maps.app.goo.gl/Wv1rwxbsBFPpA4kc6',
      'open': '09:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Gaia Vets Singapore (Jalan Besar)',
      'lat': 1.3142899313027274,
      'lng': 103.85984047422093,
      'address': '415 Jln Besar, Singapore 209016',
      'rating': 4.2,
      'tel': '69504533',
      'mapUrl': 'https://maps.app.goo.gl/usRMcd7LQVK45fAbA',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'Gaia Vets Singapore (Parksuites)',
      'lat': 1.3207480818422879,
      'lng': 103.78215515106633,
      'address': '24 Holland Grove Rd, #01-12/13, Singapore 278803',
      'rating': 4.7,
      'tel': '67277511',
      'mapUrl': 'https://maps.app.goo.gl/dhUS3cAn2GkyRQW87',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'Gaia Vets Singapore (Opal Crescent)',
      'lat': 1.3278456671833492,
      'lng': 103.86724997110633,
      'address': '5 Opal Cres, Singapore 328400',
      'rating': 'N.A.',
      'tel': '69504533',
      'mapUrl': 'https://maps.app.goo.gl/hUz3iTthS8gZyoCXA',
      'tempClosed': false,
    },
    {
      'name': 'Genesis Veterinary Clinic',
      'lat': 1.4254086599169535,
      'lng': 1103.83680518045934,
      'address': 'Yishun Central 1, #01-43 Block 935, Singapore 760935',
      'rating': 4.6,
      'tel': '62570682',
      'mapUrl': 'https://maps.app.goo.gl/AHsjquBaLByKWLup8',
      'open': '09:30',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Gentle Oak Veterinary Clinic',
      'lat': 1.3108028233631015,
      'lng': 103.78913068230794,
      'address': 'Blk 21 Ghim Moh Rd, #01-225, Singapore 270021',
      'rating': 4.6,
      'tel': '62508001',
      'mapUrl': 'https://maps.app.goo.gl/56zrXKEFJ4CsSAef9',
      'open': '09:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Hillside Veterinary Surgery',
      'lat': 1.3557730477856411,
      'lng': 103.87938538250611,
      'address': '787A Upper Serangoon Rd, Singapore 534655',
      'rating': 4.4,
      'tel': '69095338',
      'mapUrl': 'https://maps.app.goo.gl/nDnfuBTeS9fh2L8H6',
      'open': '09:30',
      'close': '21:30',
      'tempClosed': false,
    },
    {
      'name': 'Hope Veterinary Care',
      'lat': 1.3630545146276976,
      'lng': 103.88761780929481,
      'address': '1017 Upper Serangoon Rd, Singapore 534755',
      'rating': 4.3,
      'tel': '65189116',
      'mapUrl': 'https://maps.app.goo.gl/vwnWfgVNMgjzfUT38',
      'open': '09:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Island Veterinary Clinic',
      'lat': 1.3407822850084299,
      'lng': 103.73424709772439,
      'address': '114 Jurong East St 13, Block 114 01-404, Singapore 600114',
      'rating': 4.3,
      'tel': '65605991',
      'mapUrl': 'https://maps.app.goo.gl/iKZh1w8vNx86z1Y77',
      'open': '09:00',
      'close': '19:30',
      'tempClosed': false,
    },
    {
      'name': 'James Tan Veterinary Centre',
      'lat': 1.3259436562879885,
      'lng': 103.82729460732297,
      'address': '230 Whitley Rd, Singapore 297823',
      'rating': 3.8,
      'tel': '62531122',
      'mapUrl': 'https://maps.app.goo.gl/Xghv8QYvx3Kg7psS6',
      'open': '09:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Jireh Veterinary Clinic Pte. Ltd.',
      'lat': 1.327185840550905,
      'lng': 103.84560522600208,
      'address': '530 Balestier Rd, #01-04 Monville Mansion, Singapore 329857',
      'rating': 4.7,
      'tel': '62669566',
      'mapUrl': 'https://maps.app.goo.gl/GrH6zkD5CacbwGsb7',
      'open': '09:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'KAI VETS',
      'lat': 1.3487309601448891,
      'lng': 103.94350005749337,
      'address': '144 Tampines Street 12, #01-392, Singapore 521144',
      'rating': 4.8,
      'tel': '69808504',
      'mapUrl': 'https://maps.app.goo.gl/3pyhAUGNVsMTwRfT7',
      'open': '09:30',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'KIN VETS',
      'lat': 1.372856892790311,
      'lng': 103.76324680764797,
      'address': '780 Upper Bukit Timah Rd, Singapore 678125',
      'rating': 4.8,
      'tel': '69082980',
      'mapUrl': 'https://maps.app.goo.gl/7rCCo3W17Ct6iT438',
      'open': '09:30',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'Landon Veterinary Specialist Hospital | Pet A&E',
      'lat': 1.3364189505191248,
      'lng': 103.76885252497975,
      'address': '41 Eng Kong Terrace, Singapore 599013',
      'rating': 4.5,
      'tel': '64637228',
      'mapUrl': 'https://maps.app.goo.gl/PK2c2jnGkb7c4a8R8',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Light of Life Veterinary Clinic and Services',
      'lat': 1.3374528760486932,
      'lng': 103.92017982655571,
      'address': 'Bedok Reservoir Rd, #01-3508 Block 703, Singapore 470703',
      'rating': 3.8,
      'tel': '62433282',
      'mapUrl': 'https://maps.app.goo.gl/RzUUSBwhEM4bEvPK6',
      'open': '14:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'Maranatha Veterinary Clinic',
      'lat': 1.2742312794748152,
      'lng': 103.80902098415667,
      'address': '77 Telok Blangah Dr, #01-234, Singapore 100077',
      'rating': 4.6,
      'tel': '62730100',
      'mapUrl': 'https://maps.app.goo.gl/VN73f1bCrkTUmQNUA',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Monster Pet Vet',
      'lat': 1.2770767714549878,
      'lng': 103.83906405689713,
      'address': 'Blk 6 Everton Park, #01-16, Singapore 080006',
      'rating': 4.4,
      'tel': '63279148',
      'mapUrl': 'https://maps.app.goo.gl/cj2H2vrBAVXK9Jwj6',
      'open': '09:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Mount Pleasant Veterinary Group (Clementi)',
      'lat': 1.3269114716193458,
      'lng': 103.76864299736123,
      'address': '105 Clementi Street 12, #01-18/20, Singapore 120105',
      'rating': 4.3,
      'tel': '67768858',
      'mapUrl': 'https://maps.app.goo.gl/B31BJbtmoWTrHags9',
      'open': '09:30',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Mount Pleasant Veterinary Group (East)',
      'lat': 1.3104527988123391,
      'lng': 103.90556870420386,
      'address': '152 East Coast Rd, Singapore 428855',
      'rating': 4.6,
      'tel': '63486110',
      'mapUrl': 'https://maps.app.goo.gl/p6Ki8gcU6hfBAhz49',
      'open': '09:30',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'Mount Pleasant Veterinary Centre (North) Pte Ltd',
      'lat': 1.3729204058355946,
      'lng': 103.87415467368002,
      'address':
          '151 Serangoon North Ave. 2, #01-59 Serangoon North Village, Singapore 550151',
      'rating': 4.1,
      'tel': '62871190',
      'mapUrl': 'https://maps.app.goo.gl/wK8o7UVebhDHjdx1A',
      'open': '09:30',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Mount Pleasant Veterinary Group (Gelenggang)',
      'lat': 1.3810501424854476,
      'lng': 103.82797053653739,
      'address': '2 Jln Gelenggang, Singapore 578187',
      'rating': 4.2,
      'tel': '62517666',
      'mapUrl': 'https://maps.app.goo.gl/yv6owDKsojtBskUW7',
      'open': '09:30',
      'close': '23:00',
      'tempClosed': false,
    },
    {
      'name': 'Mount Pleasant Veterinary Group (Mandai)',
      'lat': 1.4390541146647968,
      'lng': 103.83792689591168,
      'address': '236 Yishun Ring Rd, #01-1010, Singapore 760236',
      'rating': 4.3,
      'tel': '64515242',
      'mapUrl': 'https://maps.app.goo.gl/dcmRxtGJpcdZ5Fko9',
      'open': '09:30',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Mount Pleasant Veterinary Group (Farrer)',
      'lat': 1.3268202948377519,
      'lng': 103.80702784954396,
      'address': 'BLK 3 Queens Rd, #02-141, Singapore 260003',
      'rating': 4.7,
      'tel': '62711132',
      'mapUrl': 'https://maps.app.goo.gl/ArY8Py6oLJsXkmui7',
      'open': '09:30',
      'close': '19:30',
      'tempClosed': false,
    },
    {
      'name': 'Mount Pleasant Veterinary Group (Bedok)',
      'lat': 1.3220247060070425,
      'lng': 103.94490588823994,
      'address': '158 Bedok South Ave 3, #01-577, Singapore 460158',
      'rating': 4.5,
      'tel': '64443561',
      'mapUrl': 'https://maps.app.goo.gl/LReP81ejkckbqhE59',
      'open': '09:30',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'My Family Vet (Bukit Batok)',
      'lat': 1.35007,
      'lng': 103.75991,
      'address': '265 Bukit Batok East Ave 4, #01-403, Singapore 650265',
      'rating': 3.3,
      'tel': '81026966',
      'mapUrl': 'https://maps.app.goo.gl/oCP6mKK7uWeobngKA',
      'open': '11:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Nam Sang Veterinary Clinic Pte Ltd (Balestier)',
      'lat': 1.32620,
      'lng': 103.84354,
      'address':
          '2 Balestier Rd, Balestier Hill Shopping centre, 01-697, Singapore 320002',
      'rating': 4.1,
      'tel': '62548138',
      'mapUrl': 'https://maps.app.goo.gl/H68JpchzxWBDFagTA',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Namly Veterinary Surgery (Namly)',
      'lat': 1.32440,
      'lng': 103.79665,
      'address': '74 Namly Pl, Shamrock Park, Singapore 267223',
      'rating': 4.8,
      'tel': '64694744',
      'mapUrl': 'https://maps.app.goo.gl/fKVr5r5oaxpKHozH8',
      'open': '09:30',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Oasis Vet (Venus)',
      'lat': 1.35852,
      'lng': 103.82757,
      'address': '15 Venus Rd, Singapore 574302',
      'rating': 4.6,
      'tel': '62562693',
      'mapUrl': 'https://maps.app.goo.gl/nb59sL3vAp8C1zxv5',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Ohana VetCare (Pasir Ris)',
      'lat': 1.36711,
      'lng': 103.96478,
      'address': '258 Pasir Ris Street 21, #04-01, Singapore 510258',
      'rating': 4.2,
      'tel': '62829070',
      'mapUrl': 'https://maps.app.goo.gl/UoeJ3pgFf5m9ZNNZA',
      'open': '10:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Paws N Claws Veterinary Surgery (Sin Ming)',
      'lat': 1.35308,
      'lng': 103.83631,
      'address': '6 Sin Ming Rd, #01-04 Sin Ming, Tower 2, Singapore 575585',
      'rating': 4.4,
      'tel': '88914417',
      'mapUrl': 'https://maps.app.goo.gl/U6thF3j8D5deftWP7',
      'open': '10:00',
      'close': '23:00',
      'tempClosed': false,
    },
    {
      'name':
          'P.A.W (People Animal Wellness) Veterinary Centre Pte.Ltd. (Bukit Purmei)',
      'lat': 1.27471,
      'lng': 103.82634,
      'address': '112 Bukit Purmei Rd, #01-207, Singapore 090112',
      'rating': 4.2,
      'tel': '62737573',
      'mapUrl': 'https://maps.app.goo.gl/26H6o8mKBzDSkQsR9',
      'open': '09:30',
      'close': '12:00',
      'tempClosed': false,
    },
    {
      'name': 'Passion Veterinary Clinic Pte Ltd (Woodlands)',
      'lat': 1.43822,
      'lng': 103.78229,
      'address': 'Blk 111 Woodlands Street 13, #01-86, Singapore 730111',
      'rating': 4.4,
      'tel': '66358725',
      'mapUrl': 'https://maps.app.goo.gl/FARBBXGDyhzuz5aH6',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Pet Care Centre & Clinic (Waringin)',
      'lat': 1.32442,
      'lng': 103.91915,
      'address': '4 Waringin Pk, Singapore 416318',
      'rating': 4.1,
      'tel': '6448583533',
      'mapUrl': 'https://maps.app.goo.gl/h8SdeCqYmHgxpvEv8',
      'open': '10:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'PET CLINIC PTE LTD (Serangoon)',
      'lat': 1.35664,
      'lng': 103.87372,
      'address':
          '211 Serangoon Ave 4, #01-12 Serangoon Green, Singapore 550211',
      'rating': 4.7,
      'tel': '62885565',
      'mapUrl': 'https://maps.app.goo.gl/bbPKf7GB3WKZKYqd8',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'PETS AVENUE VETERINARY CLINIC (Farrer Road)',
      'lat': 1.32040,
      'lng': 103.80659,
      'address': '8 Empress Rd, #01-11, Singapore 260008',
      'rating': 4.5,
      'tel': '64710111',
      'mapUrl': 'https://maps.app.goo.gl/Yed8eGF2dLMDFFwX7',
      'open': '09:00',
      'close': '21:30',
      'tempClosed': false,
    },
    {
      'name': 'PETS AVENUE VETERINARY CLINIC (Beauty World)',
      'lat': 1.34478,
      'lng': 103.77377,
      'address': '50 Jalan Jurong Kechil, JK Building, Singapore 598578',
      'rating': 4.3,
      'tel': '63630333',
      'mapUrl': 'https://maps.app.goo.gl/8rkYJq3c3YmYLGH77',
      'open': '09:00',
      'close': '21:30',
      'tempClosed': false,
    },
    {
      'name': 'PETS AVENUE VETERINARY CLINIC (Upper Thomson)',
      'lat': 1.36726,
      'lng': 103.83952,
      'address': '193 Upper Thomson Rd, Singapore 574338',
      'rating': 4.7,
      'tel': '62590555',
      'mapUrl': 'https://maps.app.goo.gl/niH84dTDqYLYgGz19',
      'open': '09:00',
      'close': '09:30',
      'tempClosed': false,
    },
    {
      'name': 'PETS AVENUE VETERINARY CLINIC (River Valley)',
      'lat': 1.30342,
      'lng': 103.84089,
      'address': '241 River Valley Rd, #02-01, Singapore 238298',
      'rating': 4.4,
      'tel': '69930333',
      'mapUrl': 'https://maps.app.goo.gl/XuetPSg9bKxdSrzr8',
      'open': '09:00',
      'close': '00:00',
      'tempClosed': false,
    },
    {
      'name': 'Point Veterinary Surgery (Jurong)',
      'lat': 1.35167,
      'lng': 103.71610,
      'address': '541 Jurong West Ave 1, #01-1044, Singapore 640541',
      'rating': 3.9,
      'tel': '64256772',
      'mapUrl': 'https://maps.app.goo.gl/mmG4QCb92YAvq6ac7',
      'open': '10:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'SingVet Animal Clinic (Woodlands)',
      'lat': 1.44738,
      'lng': 103.79850,
      'address': '768 Woodlands Ave 6, #01-11 Woodlands Mart, Singapore 730768',
      'rating': 4.2,
      'tel': '63650308',
      'mapUrl': 'https://maps.app.goo.gl/4Fwp3FjTU6vBHTef6',
      'open': '09:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'SORA VET (Chai Chee)',
      'lat': 1.32548,
      'lng': 103.92631,
      'address': '37 Chai Chee Ave, #01-291, Singapore 461037',
      'rating': 4.8,
      'tel': '60221707',
      'mapUrl': 'https://maps.app.goo.gl/TYWtX2pXpY6xF1Vs5',
      'open': '09:30',
      'close': '18:30',
      'tempClosed': false,
    },
    {
      'name': 'Society for the Prevention of Cruelty to Animals (SPCA)',
      'lat': 1.38057,
      'lng': 103.73208,
      'address': '50 Sungei Tengah Rd, Singapore 699012',
      'rating': 4.4,
      'tel': '62875355',
      'mapUrl': 'https://maps.app.goo.gl/UTedE4LDLkbGE3mYA',
      'open': '11:00',
      'close': '16:00',
      'tempClosed': false,
    },
    {
      'name': 'Spring Veterinary Care',
      'lat': 1.35340,
      'lng': 103.88629,
      'address': '123 Hougang Ave 1, #01-1412, Singapore 530123',
      'rating': 4.3,
      'tel': '62863313',
      'mapUrl': 'https://maps.app.goo.gl/gRtx8cmZk5r42A7w9',
      'open': '10:30',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'Spring Veterinary Care @ Punggol',
      'lat': 1.40291,
      'lng': 103.91384,
      'address': '681 Punggol Dr., #01-16A Oasis Terraces, Singapore 820681',
      'rating': 4.0,
      'tel': '62441469',
      'mapUrl': 'https://maps.app.goo.gl/GHYucYXHHg9YhMip9',
      'open': '10:30',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'Stars Veterinary Clinic',
      'lat': 1.3598,
      'lng': 103.88765,
      'address': '211 Hougang St 21, #01-301, Singapore 530211',
      'rating': 3.8,
      'tel': '62809880',
      'mapUrl': 'https://maps.app.goo.gl/H4kGaWXKRefGo25PA',
      'open': '09:30',
      'close': '21:30',
      'tempClosed': false,
    },
    {
      'name': 'The Animal Doctors (Tiong Bahru)',
      'lat': 1.2865,
      'lng': 103.82882,
      'address': '11A Boon Tiong Rd, #02-07/08, Singapore 161011',
      'rating': 4.4,
      'tel': '62533023',
      'mapUrl': 'https://maps.app.goo.gl/5pCK6a8gtYR9qQQw5',
      'open': '09:30',
      'close': '13:00',
      'tempClosed': false,
    },
    {
      'name': 'The Animal Doctors (Ang Mo Kio)',
      'lat': 1.37124,
      'lng': 103.83841,
      'address': '108 Ang Mo Kio Ave 4, #01-96, Singapore 560108',
      'rating': 4.1,
      'tel': '64514531',
      'mapUrl': 'https://maps.app.goo.gl/5pCK6a8gtYR9qQQw5',
      'open': '10:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'The Cat Vet',
      'lat': 1.32393,
      'lng': 103.77860,
      'address': '2 Pandan Valley, B1-204D Acacia Court, Singapore 597626',
      'rating': 4.8,
      'tel': '63632272',
      'mapUrl': 'https://maps.app.goo.gl/5pCK6a8gtYR9qQQw5',
      'open': '10:30',
      'close': '17:30',
      'tempClosed': false,
    },
    {
      'name': 'The Eye Specialist for Animals',
      'lat': 1.30672,
      'lng': 103.89599,
      'address': '299 Tanjong Katong Rd, Singapore 437082',
      'rating': 4.4,
      'tel': '62412011',
      'mapUrl': 'https://maps.app.goo.gl/y2eYu3isJbcbwKjB6',
      'open': '08:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'The Joyous Vet',
      'lat': 1.37848,
      'lng': 103.73892,
      'address': 'Choa Chu Kang Ave 3, Blk 475, Singapore 680475',
      'rating': 3.6,
      'tel': '67690304',
      'mapUrl': 'https://maps.app.goo.gl/jffbaT3bzPQ7RXbP8',
      'open': '13:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Canopy Veterinary Centre ',
      'lat': 1.32624,
      'lng': 103.72441,
      'address': '1 Yuan Ching Rd, #03-03, Singapore 618640',
      'rating': 4.6,
      'tel': '69808582',
      'mapUrl': 'https://maps.app.goo.gl/BaZrnkiYPvGQmn7p7',
      'open': '10:00',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': ' The Veterinary Clinic @ Tampines Pte Ltd ',
      'lat': 1.36563,
      'lng': 103.95178,
      'address': '476 Tampines Street 44, #01-201, Singapore 520476',
      'rating': 4.3,
      'tel': '67842048',
      'mapUrl': 'https://maps.app.goo.gl/AP45xnJCjAvW9ELTA',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'The Veterinary Clinic',
      'lat': 1.31078,
      'lng': 103.79504,
      'address': '31 Lor Liput, Singapore 277742',
      'rating': 4.6,
      'tel': '64686312',
      'mapUrl': 'https://maps.app.goo.gl/stYgiK6iLFvU3Fzg6',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Toa Payoh Vets Pte Ltd',
      'lat': 1.33505,
      'lng': 103.86140,
      'address': '1002 Lor 8 Toa Payoh, #01-1477, Singapore 319074',
      'rating': 4.2,
      'tel': '62543326',
      'mapUrl': 'https://maps.app.goo.gl/k39PiR8mUL2A2SZE9',
      'open': '09:30',
      'close': '18:30',
      'tempClosed': false,
    },
    {
      'name': 'Town Vets',
      'lat': 1.28903,
      'lng': 103.82904,
      'address': '22 Havelock Rd, #01-687, Singapore 160022',
      'rating': 4.7,
      'tel': '62767026',
      'mapUrl': 'https://maps.app.goo.gl/r5zxShCBZxwramEQ8',
      'open': '09:30',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'The Animal Clinic',
      'lat': 1.3231912734585103,
      'lng': 103.77042696408621,
      'address': '109 Clementi Street 11, #01-17/19, Singapore 120109',
      'rating': 4.3,
      'tel': '67763450',
      'mapUrl': 'https://maps.app.goo.gl/muA9NuqUkZmyTq8cA',
      'open': '09:00',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'The Animal Clinic (Katong)',
      'lat': 1.311959932589031,
      'lng': 103.9106048767237,
      'address': '55 Lor L Telok Kurau, #01-63 Singapore 425500',
      'rating': 'N.A.',
      'tel': '64404767',
      'mapUrl': 'https://maps.app.goo.gl/HqPa58Q8P8hR5mDJ6',
      'tempClosed': false,
    },
    {
      'name': 'THE CAT CLINIC',
      'lat': 1.3222745719290132,
      'lng': 103.77060522333555,
      'address': '109 Clementi Street 11, #01 33, Singapore 120109',
      'rating': 'N.A',
      'tel': '67763450',
      'mapUrl': 'https://maps.app.goo.gl/1vvX24iNRiZUhP36A',
      'tempClosed': false,
    },
    {
      'name': 'The Gentle Vet',
      'lat': 1.306706035708747,
      'lng': 103.8958111472167,
      'address': '291 Tanjong Katong Rd, Singapore 437074',
      'rating': 4.6,
      'tel': '66553970',
      'mapUrl': 'https://maps.app.goo.gl/gQHf7NKJjjKMpAR17',
      'open': '09:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'TP Animal Clinic & Wellness',
      'lat': 1.3449104584666327,
      'lng': 103.93375538491823,
      'address':
          '21 Tampines Ave 1, Block 8A, Level 1, B Next to Carpark, Singapore 529757, Temasek Polytechnic',
      'rating': 4.7,
      'tel': '67806969',
      'mapUrl': 'https://maps.app.goo.gl/bSMYoD7Df3WrJkkNA',
      'open': '09:00',
      'close': '17:00',
      'tempClosed': false,
    },
    {
      'name': 'United Veterinary Clinic Pte Ltd',
      'lat': 1.3715063423802532,
      'lng': 103.83749343313325,
      'address': '107 Ang Mo Kio Ave 4, #01-148, Singapore 560107',
      'rating': 3.9,
      'tel': '64556880',
      'mapUrl': 'https://maps.app.goo.gl/3zBfs7QvuFHHgRfx8',
      'open': '09:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Vet Affinity',
      'lat': 1.349103964152756,
      'lng': 103.74407610929487,
      'address': 'Bukit Batok Street 11, #01-248 Blk 151, Singapore 650151',
      'rating': 4.5,
      'tel': '69707505',
      'mapUrl': 'https://maps.app.goo.gl/CpLaDVuvyJhneEHw7',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Vet Affinity',
      'lat': 1.349103964152756,
      'lng': 103.74407610929487,
      'address': 'Bukit Batok Street 11, #01-248 Blk 151, Singapore 650151',
      'rating': 4.5,
      'tel': '69707505',
      'mapUrl': 'https://maps.app.goo.gl/CpLaDVuvyJhneEHw7',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Vet Central Pte. Ltd. (Toa Payoh)',
      'lat': 1.3352253580673346,
      'lng': 103.85240584811301,
      'address': '69 Lor 4 Toa Payoh, #01-357, Singapore 310069',
      'rating': 4.5,
      'tel': '66358646',
      'mapUrl': 'https://maps.app.goo.gl/HWhnctXGzRLpUPXu6',
      'open': '09:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'VET CENTRAL (SWAN LAKE) PTE LTD',
      'lat': 1.321544578143424,
      'lng': 103.92413350929475,
      'address': '9 Swan Lake Ave, Singapore 455708',
      'rating': 4.8,
      'tel': '63468646',
      'mapUrl': 'https://maps.app.goo.gl/iQvTRVTZ9hSnDGt56',
      'open': '09:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Vet Practice Pte Ltd (Lorong Kilat)',
      'lat': 1.3434102161875083,
      'lng': 103.7736267286944,
      'address': '21 Lor Kilat, #01-04 Sun Court, Singapore 598123',
      'rating': 4.1,
      'tel': '64621757',
      'mapUrl': 'https://maps.app.goo.gl/rodc8vH2oZgKHDx76',
      'open': '09:00',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'Vet Practice (Holland branch)',
      'lat': 1.3118031132347434,
      'lng': 103.79698280225377,
      'address': '31 Holland Cl, #01-219, Singapore 270031',
      'rating': 4.2,
      'tel': '67785285',
      'mapUrl': 'https://maps.app.goo.gl/V3MCcGendFarBUuC8',
      'open': '09:00',
      'close': '20:30',
      'tempClosed': false,
    },
    {
      'name': 'Vets for Life Animal Clinic (Tanjong Katong)',
      'lat': 1.3068288122711957,
      'lng': 103.89593179273949,
      'address': '330A Tanjong Katong Rd, Singapore 437106',
      'rating': 4.3,
      'tel': '63488346',
      'mapUrl': 'https://maps.app.goo.gl/9t8zmqAAoPzBLqky6',
      'open': '09:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Vets for Life Animal Clinic (River Valley)',
      'lat': 1.2950544406669382,
      'lng': 103.82692833351842,
      'address':
          '491 River Valley Rd, #01-05/06 Valley Point Shopping Centre, Singapore 248371',
      'rating': 4.5,
      'tel': '67320273',
      'mapUrl': 'https://maps.app.goo.gl/SC2a7UoftgcqUnzG6',
      'open': '09:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Vets for Life Animal Clinic (Holland Village)',
      'lat': 1.3123077693268101,
      'lng': 103.7956144151693,
      'address': '27A Lor Liput, Singapore 277738',
      'rating': 4.6,
      'tel': '69707070',
      'mapUrl': 'https://maps.app.goo.gl/xZfG9C4Jc3yA2RWi7',
      'open': '09:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Vets for Pets (Jurong West)',
      'lat': 1.3456841434244673,
      'lng': 103.71764923534828,
      'address': '519 Jurong West Street 52, Singapore 640519',
      'rating': 3.9,
      'tel': '65691627',
      'mapUrl': 'https://maps.app.goo.gl/67KBvV6aUVkvwXep8',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Vets for Pets (Lengkok Bahru)',
      'lat': 1.2885272517800352,
      'lng': 103.81403930744597,
      'address': '57 Lengkok Bahru, #01-475, Singapore 151057',
      'rating': 4.7,
      'tel': '82684039',
      'mapUrl': 'https://maps.app.goo.gl/YZLCAWWB5zNoee1e9',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'VetMedic Animal Clinic & Surgery',
      'lat': 1.4437691088668416,
      'lng': 103.82616249765026,
      'address': '52 Jln Malu-malu, Singapore 769667',
      'rating': 4.7,
      'tel': '60150393',
      'mapUrl': 'https://maps.app.goo.gl/a4VWMeJqH6mpre2T8',
      'open': '09:30',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'West Coast Vetcare',
      'lat': 1.303576067750599,
      'lng': 103.76837612463686,
      'address': '612 Clementi West Street 1, #01-300, Singapore 120612',
      'rating': 4.5,
      'tel': '67777423',
      'mapUrl': 'https://maps.app.goo.gl/PyQKpNTDmCV5GRGq7',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Westside Vet Emergency & Referral Hospital',
      'lat': 1.3646797434503002,
      'lng': 103.86498141114352,
      'address': '86 Serangoon Garden Way, Singapore 555982',
      'rating': 4.1,
      'tel': '69310095',
      'mapUrl': 'https://maps.app.goo.gl/sHAtWDmsUpPu5WLh6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Woodgrove Veterinary Services',
      'lat': 1.4352530371929053,
      'lng': 103.7844606074463,
      'address': '10 Woodlands Square, Solo 1, #01-41 Woods Square, 737714',
      'rating': 4.1,
      'tel': '60380490',
      'mapUrl': 'https://maps.app.goo.gl/HosLyuKrnQXdiKhc9',
      'open': '09:00',
      'close': '17:30',
      'tempClosed': false,
    },
    {
      'name': 'ZumVet Clinic',
      'lat': 1.3644581584125497,
      'lng': 103.85546856406658,
      'address': '416 Ang Mo Kio Ave 10, #01-973, Singapore 560416',
      'rating': 4.9,
      'tel': '31583942',
      'mapUrl': 'https://maps.app.goo.gl/wfCxnYjJ2nPYyx3s8',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
  ];

  double _currentZoom = 13.0;

  bool _isTempClosed(Map<String, dynamic> p) => (p['tempClosed'] == true);
  bool _hasHours(Map<String, dynamic> p) =>
      p.containsKey('open') || p.containsKey('close');
  bool _is24H(Map<String, dynamic> p) =>
      (p['open'] ?? '').toString().toUpperCase() == '24H' ||
      (p['close'] ?? '').toString().toUpperCase() == '24H';

  int? _toMinutes(String? hhmm) {
    if (hhmm == null) return null;
    final s = hhmm.trim();
    if (s.isEmpty || s.toUpperCase() == '24H') return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  bool _isOpenNow(Map<String, dynamic> p) {
    if (_isTempClosed(p)) return false;
    if (!_hasHours(p)) return true;
    if (_is24H(p)) return true;

    final now = DateTime.now();
    final minutesNow = now.hour * 60 + now.minute;

    final openMin = _toMinutes(p['open']?.toString());
    final closeMin = _toMinutes(p['close']?.toString());
    if (openMin == null || closeMin == null) return true;

    if (closeMin > openMin) {
      return minutesNow >= openMin && minutesNow < closeMin;
    } else {
      return minutesNow >= openMin || minutesNow < closeMin;
    }
  }

  String _statusText(Map<String, dynamic> p) {
    if (_isTempClosed(p)) return 'Temporarily closed';
    if (!_hasHours(p)) return 'Status unknown';
    if (_is24H(p)) return 'Open 24 hours';
    return _isOpenNow(p) ? 'Open now' : 'Closed now';
  }

  String _hoursLine(Map<String, dynamic> p) {
    if (_isTempClosed(p)) return 'Hours: —';
    if (!_hasHours(p)) return 'Hours: Unknown';
    if (_is24H(p)) return 'Hours: 24 hours';
    return 'Hours: ${p['open']}-${p['close']}';
  }

  Color _markerColor(Map<String, dynamic> p) {
    if (_isTempClosed(p)) return Colors.black;
    if (!_hasHours(p)) return Colors.blue;
    if (_is24H(p)) return Colors.red;
    return _isOpenNow(p) ? Colors.red : Colors.amber;
  }

  List<Map<String, dynamic>> get _filteredVets {
    if (_searchText.isEmpty) {
      return vets;
    }
    return vets
        .where(
          (vet) => vet['name'].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          ),
        )
        .toList();
  }

  void _updateSelectedVets(LatLng center) {
    const double maxDistanceMeters = 1000; // 1km radius for example
    setState(() {
      _selectedVets = _filteredVets.where((vet) {
        final vetLatLng = LatLng(vet['lat'], vet['lng']);
        final Distance distanceCalculator = Distance();
        final distance = distanceCalculator(
          center,
          vetLatLng,
        ); // Using latlong2 package distance
        return distance <= maxDistanceMeters;
      }).toList();
    });
  }

  LatLng? _currentCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _currentCenter = const LatLng(1.3521, 103.8198);
    _updateSelectedVets(_currentCenter!);
    _searchController.addListener(() {
      final text = _searchController.text.toLowerCase();
      setState(() {
        _searchText = text;

        if (text.isEmpty) {
          _selectedVet = null;
          _showSuggestions = false;
          _suggestions = [];
        } else {
          _showSuggestions = true;
          _suggestions = vets.where((item) {
            final name = item['name'].toString().toLowerCase();
            return name.contains(text);
          }).toList();

          if (_currentCenter != null) {
            _updateSelectedVets(_currentCenter!);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchAndZoom() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    // Search in filtered or all list (use filtered to support partial search)
    Map<String, dynamic>? match;
    for (var item in _filteredVets) {
      final name = item['name'].toString().toLowerCase();
      if (name.contains(query)) {
        match = item;
        break;
      }
    }

    if (match != null) {
      final lat = match['lat'] as double;
      final lng = match['lng'] as double;
      final target = LatLng(lat, lng);

      // Move the map
      _mapController.move(target, 17);

      // Update selected item to show sliding card
      setState(() {
        _selectedVet = match;
      });
    } else {
      // Optionally show a message if no match found
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No matching Vet found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_hospital_outlined, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Vets in Singapore',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showSuggestions ? 208 : 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Vets by name...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _searchAndZoom();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onSubmitted: (value) {
                    _searchAndZoom();
                  },
                ),
                if (_showSuggestions)
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          title: Text(item['name']),
                          onTap: () {
                            _searchController.text = item['name'];
                            _searchAndZoom();
                            setState(() {
                              _showSuggestions = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(1.3521, 103.8198),
              initialZoom: 12,
              onPositionChanged: (position, hasGesture) {
                _currentZoom = position.zoom;
                _currentCenter = position.center;

                if (_currentCenter == null) {
                  if (_selectedVet != null) {
                    setState(() {
                      _selectedVet = null;
                    });
                  }
                  return;
                }

                final center = _currentCenter!;
                Map<String, dynamic>? nearestVet;
                double nearestDistance = double.infinity;

                // Use filtered vets if searching, else all vets
                final vetsToSearch = _searchText.isNotEmpty
                    ? _filteredVets
                    : vets;

                for (var vet in vetsToSearch) {
                  final vetLatLng = LatLng(vet['lat'], vet['lng']);
                  final distanceCalculator = Distance();
                  final distance = distanceCalculator(center, vetLatLng);

                  if (distance < nearestDistance) {
                    nearestDistance = distance;
                    nearestVet = vet;
                  }
                }

                if (nearestVet != null) {
                  if (_searchText.isNotEmpty) {
                    // Always show nearest vet when searching
                    if (nearestVet != _selectedVet) {
                      setState(() {
                        _selectedVet = nearestVet;
                      });
                    }
                  } else {
                    // Only show vet if zoomed in enough
                    if (_currentZoom >= 16.5) {
                      if (nearestVet != _selectedVet) {
                        setState(() {
                          _selectedVet = nearestVet;
                        });
                      }
                    } else {
                      // Zoomed out: hide sliding card
                      if (_selectedVet != null) {
                        setState(() {
                          _selectedVet = null;
                        });
                      }
                    }
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: vets.map((run) {
                  final color = _markerColor(run);
                  return Marker(
                    point: LatLng(run['lat'], run['lng']),
                    width: 44,
                    height: 44,
                    child: Tooltip(
                      message: run['name'],
                      child: GestureDetector(
                        onTap: () {
                          if (_currentZoom >= 16.5) {
                            setState(() {
                              _selectedVet = run;
                            });
                          } else {
                            // Zoom in first and store the target vet
                            _mapController.move(
                              LatLng(run['lat'], run['lng']),
                              17,
                            );
                          }

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(run['name']),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Address with copy
                                  if (run['address'] != null)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            run['address'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: run['address'],
                                              ),
                                            );
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Address copied!",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),

                                  // Show tel number
                                  if (run['tel'] != null)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Tel: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: SelectableText(run['tel']),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(text: run['tel']),
                                            );
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Phone number copied!",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _statusText(run),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_hoursLine(run)),
                                  const SizedBox(height: 8),
                                  if (run['rating'] != null)
                                    Text('Rating: ${run['rating']} ⭐'),
                                  const SizedBox(height: 12),
                                  if (run['mapUrl'] != null)
                                    InkWell(
                                      onTap: () async {
                                        final url = run['mapUrl'].toString();
                                        if (await canLaunchUrl(
                                          Uri.parse(url),
                                        )) {
                                          await launchUrl(
                                            Uri.parse(url),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            ctx,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not open Google Maps',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Open in Google Maps',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BookAppointmentPage(vetData: run),
                                        ),
                                      );
                                    },
                                    child: const Text('Book Appointment'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(Icons.location_on, color: color, size: 40),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Sliding bottom card:
          if (_selectedVet != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () async {
                  final url =
                      _selectedVet!['mapUrl'] ??
                      'https://www.google.com/maps/search/?api=1&query=${_selectedVet!['lat']},${_selectedVet!['lng']}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedVet!['name'] ?? 'Unknown Vet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedVet!['rating'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Rating: ${_selectedVet!['rating']} ⭐'),
                        ),
                      if (_selectedVet != null) ...[
                        Text(
                          _statusText(_selectedVet!),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _markerColor(_selectedVet!),
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                      if (_selectedVet!['tel'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Tel: ${_selectedVet!['tel']}'),
                        ),
                      SizedBox(height: 8),
                      Text(
                        'Tap here to open in Google Maps',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Legend at bottom right:
          Positioned(
            bottom: 20,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem(Colors.red, "Open"),
                  _legendItem(Colors.amber, "Closed"),
                  _legendItem(Colors.black, "Temporarily closed"),
                  _legendItem(Colors.blue, "Status unknown"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _legendItem(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.location_on, color: color, size: 20),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 13)),
    ],
  );
}
