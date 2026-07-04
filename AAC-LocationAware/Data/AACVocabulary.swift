import Foundation

struct AACVocabulary {
    static let coreWords: [Word] = [
        // Pronouns
        Word(label: "I",        arasaacId: 6632),
        Word(label: "You"),
        Word(label: "We"),
        Word(label: "It",       arasaacId: 31670),
        Word(label: "My"),
        Word(label: "Your"),

        // Core verbs
        Word(label: "Want",     arasaacId: 5441),
        Word(label: "Need"),
        Word(label: "Like",     arasaacId: 37826),
        Word(label: "Go"),
        Word(label: "Stop"),
        Word(label: "Help"),

        Word(label: "Eat"),
        Word(label: "Drink"),
        Word(label: "Play"),
        Word(label: "Look"),
        Word(label: "Come"),
        Word(label: "Give"),

        Word(label: "Open"),
        Word(label: "Close"),
        Word(label: "Put"),
        Word(label: "Make"),
        Word(label: "Turn"),
        Word(label: "Do"),

        // Social / response
        Word(label: "Yes"),
        Word(label: "No",       arasaacId: 5526),
        Word(label: "More"),
        Word(label: "All done"),
        Word(label: "Please"),
        Word(label: "Wait"),

        Word(label: "Thank you"),
        Word(label: "Sorry"),
        Word(label: "Hello"),
        Word(label: "Bye"),
        Word(label: "Not"),
        Word(label: "Again"),

        // Feelings
        Word(label: "Happy"),
        Word(label: "Sad"),
        Word(label: "Angry"),
        Word(label: "Scared"),
        Word(label: "Tired"),
        Word(label: "Hurt"),

        Word(label: "Good"),
        Word(label: "Bad"),
        Word(label: "Sick"),
        Word(label: "Hungry"),
        Word(label: "Thirsty"),
        Word(label: "Hot"),

        // Descriptors / location
        Word(label: "Big"),
        Word(label: "Little"),
        Word(label: "Fast"),
        Word(label: "Slow"),
        Word(label: "Loud"),
        Word(label: "Quiet"),

        Word(label: "Here"),
        Word(label: "There",    arasaacId: 5375),
        Word(label: "In",       arasaacId: 7034),
        Word(label: "On",       arasaacId: 21818),
        Word(label: "Up"),
        Word(label: "Out"),

        // Questions
        Word(label: "What"),
        Word(label: "Where"),
        Word(label: "Who"),
        Word(label: "Why"),
        Word(label: "When"),
        Word(label: "How"),

        // Misc
        Word(label: "That"),
        Word(label: "Mine"),
        Word(label: "Same"),
        Word(label: "Different"),
        Word(label: "Some"),
        Word(label: "All"),
    ]

    static let searchAliases: [String: String] = [
        "eat": "eating", "drink": "drinking",
        "i want": "want", "i need": "need",
        "all done": "finished", "go home": "home",
        "watch tv": "television", "more time": "wait",
        "wash hands": "handwashing", "brush teeth": "toothbrush",
        "wake up": "wake", "light on": "lamp on", "light off": "lamp off",
        "privacy": "private", "together": "family",
        "i": "myself", "you": "pointing", "we": "us",
        "done": "finished", "go": "walk", "look": "look at",
        "fun": "play", "loud": "noise",
        "yes": "yes", "no": "no", "please": "please",
        "thank you": "thank", "hello": "greeting",
        "stop": "stop", "wait": "wait", "help": "help",
        "read": "reading", "write": "writing",
        "listen": "listening", "talk": "talking",
        "relax": "relaxing", "play": "playing",
        "sit": "sitting", "sleep": "sleeping",
        "music": "music", "quiet": "quiet",
        "cook": "cooking", "swing": "swinging",
        "run": "running", "walk": "walking",
        "scared": "fear", "tired": "tired", "hug": "hug",
        "snack": "snack", "break": "break", "question": "question",
    ]

    static let roomWords: [String: [Word]] = [
        "common": [],   // fallback room when no beacon detected
        "kitchen": [
            "food","water","drink","eat","hungry","thirsty",
            "breakfast","lunch","dinner","snack","milk","juice",
            "apple","banana","bread","cereal","spoon","fork","cup","plate","bowl","cook"
        ].map { Word(label: $0) },

        "bathroom": [
            "bathroom","toilet","wash","soap","toothbrush","towel",
            "shower","bath","sink","potty","privacy","flush","hand"
        ].map { Word(label: $0) } + [
            Word(label: "brush teeth"), Word(label: "wash hands")
        ],

        "bedroom": [
            "bed","sleep","tired","blanket","pillow","night","light",
            "quiet","pajamas","story","book"
        ].map { Word(label: $0) } + [
            Word(label: "light on"), Word(label: "light off"), Word(label: "wake up")
        ],

        "livingroom": [
            "play","music","tv","watch","toy","game","puzzle",
            "ball","book","read","sit","couch","sofa","together","relax"
        ].map { Word(label: $0) },

        "classroom": [
            "school","teacher","question","answer","read","write",
            "listen","pencil","paper","book","break","lesson","math","science","story"
        ].map { Word(label: $0) } + [
            Word(label: "more time")
        ],

        "outside": [
            "outside","walk","run","play","swing","slide","park",
            "playground","sun","rain","snow","tree","flower","bike","ball"
        ].map { Word(label: $0) } + [
            Word(label: "go home")
        ],
    ]
}
