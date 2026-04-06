An example of using SKILLS.md within an BAML agent.

See our [Ship it Fridays](https://youtu.be/xVqrsWUEjUI?si=gmxTVs38IB0WAmgj&t=40)
video for a high-level walkthrough.

An second approach not covered in the video is to encode the available skills
as types and use TypeBuilder. The `skills_typebuilder.baml` and `main_typebuilder.py`
files show how you can do this. The decision to use the plain or typebuilder variant
comes down to whether you want to control the presentation of skill definitions in
your prompt manually, or to have the BAML parser to be aware of the exact skills so
that it's impossible for the LLM to pick a non-existing one.
