import Foundation

struct Shloka: Identifiable {
    let id = UUID()
    let sanskrit: String
    let sanskritLine2: String
    let transliteration: String
    let transliterationLine2: String
    let meaning: String
    let verse: String
}

let shlokaList: [Shloka] = [
    Shloka(
        sanskrit: "क्लैब्यं मा स्म गम: पार्थ नैतत्त्वय्युपपद्यते |",
        sanskritLine2: "क्षुद्रं हृदयदौर्बल्यं त्यक्त्वोत्तिष्ठ परन्तप || 2.3 ||",
        transliteration: "klaibyaṁ mā sma gamaḥ pārtha naitat tvayy upapadyate",
        transliterationLine2: "kṣhudraṁ hṛidaya-daurbalyaṁ tyaktvottiṣhṭha parantapa",
        meaning: "Do not yield to this degrading impotence. It does not become you. Give up such petty weakness of heart and arise, O vanquisher of enemies!",
        verse: "2.3"
    ),
    Shloka(
        sanskrit: "नियतं कुरु कर्म त्वं कर्म ज्यायो ह्यकरमधिकारस्ते |",
        sanskritLine2: "मा फलेषु कदाचन मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि || 2.47 ||",
        transliteration: "niyataṁ kuru karma tvāṁ karma jyāyo hy akarmādhi-kāras te",
        transliterationLine2: "mā phaleṣu kadācana mā karma-phala-hetur bhūr mā te saṅgo 'stv akarmaṇi",
        meaning: "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions. Never consider yourself to be the cause of the results of your activities, and never be attached to inaction.",
        verse: "2.47"
    ),
    Shloka(
        sanskrit: "तस्मादसक्त: सततं कार्यं कर्म समाचर |",
        sanskritLine2: "असक्तो ह्याचरन्कर्म परमाप्नोति पुरुष: || 3.8 ||",
        transliteration: "tasmād asaktaḥ satataṁ kāryaṁ karma samācara",
        transliterationLine2: "asakto hy ācaran karma param āpnoti puruṣhaḥ",
        meaning: "Therefore, without being attached to the fruits of activities, one should act as a matter of duty, for by working without attachment one attains the Supreme.",
        verse: "3.8"
    ),
    Shloka(
        sanskrit: "यदा संहरते चायं कूर्मोऽङ्गानीव सर्वश: |",
        sanskritLine2: "इन्द्रियाणीन्द्रियार्थेभ्यस्तस्य प्रज्ञा प्रतिष्ठिता || 2.58 ||",
        transliteration: "yadā saṅharate chāyaṁ kūrmo 'ṅgānīva sarvaśaḥ",
        transliterationLine2: "indriyāṇīndriyārthebhyaḥ tasya prajñā pratiṣṭhitā",
        meaning: "One who is able to withdraw the senses from their objects, as a tortoise draws its limbs within its shell, is established in divine wisdom.",
        verse: "2.58"
    ),
    Shloka(
        sanskrit: "काम एष क्रोध एष रजोगुणसमुद्भव: |",
        sanskritLine2: "महाशनो महापाप्मा विद्ध्येनमिह वैरिणम् || 3.37 ||",
        transliteration: "kāma eṣa krodha eṣa rajo-guṇa-samudbhavaḥ",
        transliterationLine2: "mahāśano mahāpāpmā viddhy enam iha vairiṇam",
        meaning: "It is lust (desire for comfort/distraction) and wrath... identify this as the enemy.",
        verse: "3.37"
    ),
    Shloka(
        sanskrit: "उद्धरेदात्मनात्मानं नात्मानमवसादयेत् |",
        sanskritLine2: "आत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मन: || 6.5 ||",
        transliteration: "uddhared ātmānātmānaṁ nātmānam avasādayet",
        transliterationLine2: "ātmai va hy ātmano bandhur ātmai va ripur ātmaṇaḥ",
        meaning: "Elevate yourself through your own mind, and do not degrade yourself. For the mind is the friend of the self, and also the enemy of the self.",
        verse: "6.5"
    )
]