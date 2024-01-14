from pathlib import Path

import json
import re

MIN_LEN = 5
MAX_LEN = 8

SKIP_FIRST = 300
TARGET_LEN = 1000

WORD_BLACKLIST = [
    "ought",
    "ebook",
    "nicht",
    "comme",
    "avait",
    "literary",
    "cette",
    "madame",
    "etext",
    "scarcely",
    "faire",
    "xpage",
    "monsieur",
    "etait",
    "einen",
    "aussi",
    "ascii",
    "votre",
    "napoleon",
    "homme",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "william",
    "richard",
    "toute",
    "israel",
    "latin",
    "arthur",
    "ireland",
    "france",
    "virginia",
    "first",
    "second",
    "third",
    "fourth",
    "fifth",
    "sixth",
    "seventh",
    "eighth",
    "ninth",
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december",
    "english",
    "mary",
    "spain",
    "fifteen",
    "french",
    "breast",
    "italy",
    "italian",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
    "germany",
    "edward",
    "irish",
    "christ",
    "roman",
    "greek",
    "india",
    "america",
    "quand",
    "chiefly",
    "spanish",
    "harry",
    "smith",
    "joseph",
    "david",
    "arthur",
    "helen",
    "russia",
    "avoir",
    "femme",
    "notre",
    "bible",
    "werden",
    "eleven",
    "seine",
    "england",
    "american",
    "twenty",
    "george",
    "yourself",
    "where",
    "what",
    "while",
    "when",
    "johnson",
    "britain",
    "german",
    "british",
    "there",
    "their",
    "henry",
    "indian",
    "fifty",
    "selbst",
    "native",
    "twelve",
    "michael",
    "europe",
    "jeune",
    "thirty",
    "those",
    "robert",
    "phillip",
    "forty",
    "slave",
    "somehow",
    "durch",
    "european",
    "hette",
    "einen",
    "thence",
    "hitherto",
    "egypt",
    "thine",
    "catholic",
    "chinese",
    "russian",
    "bosom",
    "quelque",
    "dutch",
    "grande",
    "slavery",
]


def main() -> None:
    input_file = Path(__file__).parent / "wiki-100k.txt"

    with open(input_file, "r", encoding="utf-8", errors="ignore") as f:
        words = []
        for x in f.readlines():
            try:
                words.append(x.strip().lower())
            except UnicodeDecodeError:
                continue

    target_words = []
    unique_sets = []

    for idx, word in enumerate(words):
        if idx == 386:
            print(word)
        if idx < SKIP_FIRST:
            continue
        if word.startswith("#"):
            continue
        if (
            word.endswith("s") or word.endswith("ing") or word.endswith("ed")
        ):  # No plurals on doings
            continue
        if word.lower() in WORD_BLACKLIST:
            continue
        if len(word) > MAX_LEN or len(word) < MIN_LEN:
            continue
        if not all([re.match(r"[a-z]", x) for x in word.lower()]):
            continue
        if "\\u" in word:
            continue
        if word.lower() in target_words:
            continue
        if set(word.lower()) in unique_sets:  # Ensure anagrams are unique
            continue

        target_words.append(word.lower())
        unique_sets.append(set(word.lower()))

        if len(target_words) > TARGET_LEN:
            break

    with open(Path(__file__).parent.parent / "wordlist.json", "w") as j:
        json.dump(target_words, j, indent=4)


if __name__ == "__main__":
    main()
