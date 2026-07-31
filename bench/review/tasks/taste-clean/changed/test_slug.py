from slug import slugify, unique_slug

assert slugify("Hello, World!") == "hello-world"
assert slugify("  a  b  ") == "a-b"
assert slugify("") == ""

assert unique_slug("Hello", set()) == "hello"
assert unique_slug("Hello", {"hello"}) == "hello-2"
assert unique_slug("Hello", {"hello", "hello-2"}) == "hello-3"
long_title = "word " * 30
assert len(unique_slug(long_title, set())) <= 60
print("test_slug: PASS")
