# STORE THIS IN SAME DIRECTORY AS : THE LUA FILE, HISTORY FILES

import os, sys
from openai import OpenAI

# Set up your OpenAI API credentials
client = OpenAI(api_key = os.environ["OPENAI_API_KEY"]) # linux - export OPENAI_API_KEY='key_here'

try:
    character_name = sys.argv[1]
    npc_name = sys.argv[2]
    account_name = sys.argv[3]
    dir_name = os.path.dirname(__file__)
    file_name = dir_name + "/" + character_name + "" + npc_name + ".history"
    if os.path.exists(file_name) == True: # should always be true. we will create the file with LUA. we could use sys vars here in python instead, but it introduces security errors via user input when those characters are important to conversation
        history_file = open(file_name, "r")
        history_array = []
        for line in history_file.readlines(): # load array of previous conversation here, before the AI completion
            content_split = line.split('|')
            new_data = {"role": "" + content_split[1] + "", "content": "" + content_split[2] + ""}
            history_array.append(new_data)
        history_file.close()
except:
    print("[ChatGPT:Py]: Error in making the file_name variable. Is this python file in the same directory as the history files?")
else:
    print("[ChatGPT:Py]: Successfully accessed and cached '" + file_name + "'.")

def Run_GPT():
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=history_array,
        presence_penalty=0, # bias to talk about new topics from -2.0 to 2.0
        max_tokens=50, # max amount of word/character generation. can cut off chat
        temperature=0.8, # What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
        user=account_name, # set the user/account here
    )
    
    try:
        active_file = open(file_name, "a")
        string_to_append = "\n|" + response.choices[0].message.role + "|" + response.choices[0].message.content + "|"
        active_file.write(string_to_append)
        active_file.close()
    except:
        return "Oops! Something went wrong."
Run_GPT()