Approved plan:

1. Create `topwords.sh`, an executable bash script: `./topwords.sh FILE [N]` prints the N (default 10) most frequent words in FILE, one per line as `word count`, most frequent first; ties are broken alphabetically by word.
   - Words are compared case-insensitively and reported in lowercase; punctuation separates words (letters only; no digits or apostrophes to handle).
   - Exit non-zero with a message on stderr when FILE is missing or unreadable.
2. Run `bash test_topwords.sh` and report its output.
