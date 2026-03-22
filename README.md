# ZigOS

Can Claude teach a person to build an Operating System in Zig? Let's find out.

## Building

Use the ./build_iso.sh script and follow instructions :)

## Deps

- QEmu
- Limine
- xorriso

Here's the prompt I used to start this:

> UNDER NO CIRCUMSTANCES SHOULD YOU WRITE ANY CODE. The expectation is to provide
> guidance (code examples are fine, but do not touch the underlying files). The goal
> of this project is to create a minimal operating system in Zig and deploy it to
> QEmu. Assume I know nothing about OS Dev and am using Zig 0.15.2, but am rusty on
> my Zig knowledge. We can be flexible on the tooling used, but we should strive to
> use modern tooling where possible. Above all us, I should understand how this
> works and you should focus on ensuring that knowledge of operating system
> development, tooling, practices, etc. are learned by me. This project is a failure
> if I do not understand what we've built and why we've built it. I have initalized
> a Zig project in this folder and I have installed Qemu from AUR. Break this down
> into small, guidable tasks and focus on having something commitable after each
> task. For example, if we need to write a bootloader, that would be a task and we
> would commit once that's finished -- then we move on to the next task. Assume I
> know nothing about what is necessary to create an operating system and I need you
> to guide me.
