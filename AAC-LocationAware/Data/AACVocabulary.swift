import Foundation

struct AACVocabulary {
    static let coreWords: [Word] = [
        Word(label: "I",        arasaacId: 6632),
        Word(label: "You"),
        Word(label: "It",       arasaacId: 31670),
        Word(label: "Want",     arasaacId: 5441),
        Word(label: "Need"),
        Word(label: "Like",     arasaacId: 37826),
        Word(label: "Go"),
        Word(label: "Stop"),
        Word(label: "Help"),
        Word(label: "More"),
        Word(label: "All done"),
        Word(label: "Yes"),
        Word(label: "No",       arasaacId: 5526),
        Word(label: "Not"),
        Word(label: "Here"),
        Word(label: "There",    arasaacId: 5375),
        Word(label: "In",       arasaacId: 7034),
        Word(label: "On",       arasaacId: 21818),
        Word(label: "That"),
        Word(label: "Mine"),
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
