from slug import slugify

assert slugify("Hello, World!") == "hello-world"
assert slugify("  a  b  ") == "a-b"
assert slugify("") == ""
print("test_slug: PASS")
