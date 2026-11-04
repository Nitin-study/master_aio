import 'dart:math';

class Question {
  final String q;
  final List<String> options;
  final int answer;
  const Question(this.q, this.options, this.answer);

  Question shuffled(Random r) {
    final idx = List<int>.generate(options.length, (i) => i)..shuffle(r);
    return Question(q, [for (final i in idx) options[i]], idx.indexOf(answer));
  }
}
const Map<String, Map<String, List<Question>>> bank = {
  'Maths': {
    'Percentage': [
      Question('20% of 150 = ?', ['25', '30', '35', '40'], 1),
      Question('25% of 480 = ?', ['100', '120', '125', '140'], 1),
      Question('A number increased by 10% becomes 220. Number = ?',
          ['180', '200', '210', '240'], 1),
      Question('40% of 50% of 200 = ?', ['20', '40', '60', '80'], 1),
    ],
    'Average': [
      Question('Average of 5, 10, 15, 20, 25 = ?', ['12', '15', '18', '20'], 1),
      Question('Average of first 5 natural numbers = ?',
          ['2', '3', '4', '5'], 1),
      Question('Average of 4 numbers is 20. Their sum = ?',
          ['60', '70', '80', '100'], 2),
      Question(
          '3 friends have average age 20. A 40 year old joins. New average = ?',
          ['25', '30', '28', '35'], 0),
    ],
    'Time & Work': [
      Question('A does a work in 10 days, B in 15 days. Together they finish in?',
          ['5 din', '6 din', '7 din', '8 din'], 1),
      Question('A does a work in 12 days. In 3 days he does how much?',
          ['1/3', '1/4', '1/6', '1/2'], 1),
      Question('4 men finish a work in 15 days. 6 men will finish in?',
          ['8 din', '10 din', '12 din', '9 din'], 1),
      Question('A+B finish in 8 days, A alone in 12 days. B alone = ?',
          ['16 din', '20 din', '24 din', '18 din'], 2),
    ],
    'Number System': [
      Question('HCF of 12 and 18 = ?', ['3', '6', '9', '12'], 1),
      Question('LCM of 4 and 6 = ?', ['12', '24', '10', '8'], 0),
      Question('Which is a prime number?', ['21', '29', '33', '39'], 1),
      Question('Smallest prime number?', ['0', '1', '2', '3'], 2),
    ],
  },
  'Reasoning': {
    'Series': [
      Question('2, 4, 8, 16, ?', ['24', '32', '30', '20'], 1),
      Question('3, 6, 9, 12, ?', ['14', '15', '16', '18'], 1),
      Question('1, 4, 9, 16, ?', ['20', '24', '25', '36'], 2),
    ],
    'Odd One Out': [
      Question('Odd one out', ['Apple', 'Mango', 'Potato', 'Banana'], 2),
      Question('Odd one out', ['Dog', 'Cat', 'Cow', 'Eagle'], 3),
      Question('Odd one out', ['Circle', 'Triangle', 'Square', 'Cube'], 3),
    ],
    'Direction': [
      Question('Facing North, you turn right. Now you face?',
          ['North', 'East', 'South', 'West'], 1),
      Question('Facing East, you turn left. Now you face?',
          ['North', 'South', 'West', 'East'], 0),
    ],
  },
  'English': {
    'Synonyms': [
      Question('Synonym of "Happy"', ['Sad', 'Joyful', 'Angry', 'Tired'], 1),
      Question('Synonym of "Big"', ['Small', 'Large', 'Tiny', 'Thin'], 1),
      Question('Synonym of "Quick"', ['Slow', 'Fast', 'Late', 'Weak'], 1),
    ],
    'Antonyms': [
      Question('Antonym of "Brave"', ['Strong', 'Coward', 'Bold', 'Hero'], 1),
      Question('Antonym of "Hot"', ['Warm', 'Cold', 'Cool', 'Fire'], 1),
      Question('Antonym of "Ancient"', ['Old', 'Modern', 'Past', 'Antique'], 1),
    ],
    'Grammar': [
      Question('Plural of "Child"',
          ['Childs', 'Childes', 'Children', 'Child'], 2),
      Question('She ___ to school daily.',
          ['go', 'goes', 'going', 'gone'], 1),
      Question('I have ___ apple.', ['a', 'an', 'the', 'on'], 1),
      Question('Past tense of "Eat"', ['Eaten', 'Ate', 'Eats', 'Eating'], 1),
    ],
  },
  'Hindi': {
    'पर्यायवाची': [
      Question('"सूर्य" का पर्यायवाची है', ['चंद्र', 'रवि', 'तारा', 'नभ'], 1),
      Question('"जल" का पर्यायवाची है', ['अग्नि', 'नीर', 'पवन', 'धरा'], 1),
      Question('"पृथ्वी" का पर्यायवाची है', ['धरा', 'अंबर', 'सागर', 'पवन'], 0),
    ],
    'विलोम': [
      Question('"दिन" का विलोम है', ['सुबह', 'रात', 'शाम', 'कल'], 1),
      Question('"सच" का विलोम है', ['झूठ', 'सत्य', 'साँच', 'न्याय'], 0),
      Question('"अमृत" का विलोम है', ['विष', 'जल', 'दूध', 'नीर'], 0),
    ],
    'सामान्य हिंदी': [
      Question('हिंदी दिवस कब मनाया जाता है?',
          ['14 सितंबर', '15 अगस्त', '26 जनवरी', '2 अक्टूबर'], 0),
      Question('हिंदी की लिपि कौन-सी है?',
          ['रोमन', 'देवनागरी', 'गुरमुखी', 'ब्राह्मी'], 1),
    ],
  },
  'General Science': {
    'Physics': [
      Question('SI unit of force',
          ['Joule', 'Newton', 'Watt', 'Pascal'], 1),
      Question('Speed of light is about (m/s)',
          ['3 x 10^6', '3 x 10^8', '3 x 10^5', '3 x 10^10'], 1),
      Question('SI unit of electric current',
          ['Ampere', 'Volt', 'Ohm', 'Watt'], 0),
    ],
    'Chemistry': [
      Question('Chemical formula of water', ['CO2', 'H2O', 'O2', 'NaCl'], 1),
      Question('Atomic number of Carbon', ['6', '12', '8', '14'], 0),
      Question('pH of pure water', ['0', '7', '14', '1'], 1),
    ],
    'Biology': [
      Question('Plants absorb which gas in photosynthesis?',
          ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Hydrogen'], 2),
      Question('Powerhouse of the cell',
          ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi body'], 1),
      Question('Which vitamin do we get from sunlight?',
          ['A', 'B', 'C', 'D'], 3),
      Question('How many chambers does the human heart have?',
          ['2', '3', '4', '5'], 2),
    ],
  },
  'Geography': {
    'India': [
      Question('Longest river of India (flowing within India)',
          ['Ganga', 'Yamuna', 'Godavari', 'Narmada'], 0),
      Question('Largest state of India by area',
          ['Madhya Pradesh', 'Rajasthan', 'Maharashtra', 'Uttar Pradesh'], 1),
      Question('Tropic of Cancer passes through how many Indian states?',
          ['6', '7', '8', '9'], 2),
    ],
    'World': [
      Question('Largest continent',
          ['Africa', 'Asia', 'Europe', 'Antarctica'], 1),
      Question('Largest ocean',
          ['Atlantic', 'Indian', 'Pacific', 'Arctic'], 2),
      Question('Smallest continent',
          ['Europe', 'Australia', 'Antarctica', 'Africa'], 1),
    ],
  },
  'History & Polity': {
    'History': [
      Question('First Prime Minister of India',
          ['Sardar Patel', 'Jawaharlal Nehru', 'Mahatma Gandhi', 'Rajendra Prasad'], 1),
      Question('Quit India Movement started in',
          ['1930', '1942', '1947', '1919'], 1),
      Question('Jallianwala Bagh massacre happened in',
          ['1919', '1920', '1921', '1922'], 0),
    ],
    'Polity': [
      Question('Indian Constitution came into effect on',
          ['15 Aug 1947', '26 Jan 1950', '26 Nov 1949', '2 Oct 1950'], 1),
      Question('Chairman of the Drafting Committee',
          ['Dr B.R. Ambedkar', 'Jawaharlal Nehru', 'Dr Rajendra Prasad', 'Sardar Patel'], 0),
      Question('How many Fundamental Rights are in the Constitution?',
          ['5', '6', '7', '8'], 1),
      Question('Term of the President of India (years)',
          ['4', '5', '6', '7'], 1),
    ],
  },
  'J&K GK': {
    'Geography': [
      Question('Dal Lake is in which city?',
          ['Jammu', 'Srinagar', 'Leh', 'Anantnag'], 1),
      Question('Which river flows through Srinagar?',
          ['Chenab', 'Ravi', 'Jhelum', 'Beas'], 2),
      Question('Wular Lake is known as',
          ['Biggest freshwater lake of India', 'A salt lake', 'An artificial lake', 'A glacial lake'], 0),
      Question('Zojila Pass connects Kashmir Valley with',
          ['Ladakh', 'Himachal', 'Punjab', 'Uttarakhand'], 0),
      Question('Jawahar Tunnel is located at',
          ['Banihal', 'Kupwara', 'Rajouri', 'Leh'], 0),
    ],
    'Culture & Places': [
      Question('Hazratbal Shrine is in',
          ['Jammu', 'Srinagar', 'Anantnag', 'Baramulla'], 1),
      Question('Mata Vaishno Devi shrine base town',
          ['Katra', 'Udhampur', 'Samba', 'Kathua'], 0),
      Question('Shalimar Bagh (Srinagar) was built by',
          ['Akbar', 'Jahangir', 'Shah Jahan', 'Babur'], 1),
      Question('Saffron of Kashmir is mainly grown in',
          ['Pampore', 'Gulmarg', 'Katra', 'Poonch'], 0),
    ],
    'History & Polity': [
      Question('Article 370 was abrogated in which year?',
          ['2014', '2017', '2019', '2021'], 2),
      Question('J&K Reorganisation Act 2019 created J&K UT and which other UT?',
          ['Ladakh', 'Chandigarh', 'Puducherry', 'Delhi'], 0),
    ],
  },
  'Computer': {
    'Basics': [
      Question('CPU stands for',
          ['Central Processing Unit', 'Central Program Unit', 'Control Process Unit', 'Core Processing Unit'], 0),
      Question('1 Byte = ? bits', ['4', '8', '16', '32'], 1),
      Question('Father of the computer',
          ['Charles Babbage', 'Alan Turing', 'Bill Gates', 'Steve Jobs'], 0),
      Question('RAM stands for',
          ['Random Access Memory', 'Read Access Memory', 'Run Access Memory', 'Random Active Memory'], 0),
    ],
  },
};
