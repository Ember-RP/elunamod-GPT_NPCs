# Ember's ChatGPT NPCs
Allows players to have conversations with NPCs in World of Warcraft via in-game chat and communication. A player can simply walk up to any NPC, type a chat at it, and will receive results from OpenAI.

### Current Compatibility
- [Eluna TrinityCore 3.3.5](https://github.com/ElunaLuaEngine/ElunaTrinityWotlk)
- [Azerothcore Eluna Module 3.3.5](https://github.com/azerothcore/mod-eluna)

## Requirements
- Python3
   - Pip Packages: `openai` via `pip install`
   - Easy Linux Command that installs the packages for you: `pip install openai`

## Installation Instructions
- Clone this repository into your LUA scripts folder
- In GPT_NPCs.lua, edit the following configuration values:
- - `path_to_history = "lua_scripts/elunamod-GPT_NPCs/"`
  - Path to where conversation histories are stored. Should be the same as where these .lua and .py files are located.
- - `PATH_TO_OPENAI_EVENT = "lua_script/elunamod-GPT_NPCs/GPT_NPCs.py"`
  - Path to where the python file is stored.
- Create environment variable, "OPENAI_API_KEY", via your specific system instructions.
- - Linux users : `export OPENAI_API_KEY='your_api_key'`
  - Copy and paste your specific OpenAI API key here. You can receive one from the OpenAI API website.

## Editing the Prompt
If you'd like to edit the initial AI prompt that is received, open the file `GPT_NPCS.lua` and investigate the variable `content` in the `OnPlayerChat` function.

# Licensing
This specific module is covered by the MIT License rules. Distribution and modification is entirely allowed. Please refer to its documentation for more information.
