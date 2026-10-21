from slug import MAX_SLUG_LENGTH, slugify, unique_slug

assert slugify("Hello, World!") == "hello-world"
assert slugify("  a  b  ") == "a-b"
assert slugify("") == ""

assert unique_slug("Hello", set()) == "hello"
assert unique_slug("Hello", {"hello"}) == "hello-2"
assert unique_slug("Hello", {"hello", "hello-2"}) == "hello-3"
long_title = "word " * 30
long_slug = unique_slug(long_title, set())
assert len(long_slug) <= MAX_SLUG_LENGTH
assert len(unique_slug(long_title, {long_slug})) <= MAX_SLUG_LENGTH
print("test_slug: PASS")
