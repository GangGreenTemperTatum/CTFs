# [Machine_Learning_CTF_Challenges](https://github.com/alexdevassy/Machine_Learning_CTF_Challenges) Writeup
### *Machine Learning* | *AI Security* | *AI Red Teaming* | *Walkthrough* |

😇😇 **DISCLAIMER** *Hints below!* 😇😇

PS: If using mac os, default ports for control center is 5000 and therefore suggest updating the docker build/run to 5010 or other. You need to update the flask python application code (`./app.py`) as well as the `dockerfile` and `docker run..` command. I do recommend building the apps with a `venv` and the source code if using mac to evade `empty response` HTTP calls to the container(s).

**Table of Contents**:
- [Machine\_Learning\_CTF\_Challenges Writeup](#machine_learning_ctf_challenges-writeup)
    - [*Machine Learning* | *AI Security* | *AI Red Teaming* | *Walkthrough* |](#machine-learning--ai-security--ai-red-teaming--walkthrough-)
  - [Tips on amending Docker desktop to avoid paying for a license with replacement Colima Container Runtime 🐳](#tips-on-amending-docker-desktop-to-avoid-paying-for-a-license-with-replacementcolimacontainer-runtime-)
  - [Challenges:](#challenges)
      - [CTF Challenges :open\_file\_folder:](#ctf-challenges-open_file_folder)
  - [Vault\_ML\_CTF\_Challenge](#vault_ml_ctf_challenge)
  - [Persuade\_ML\_CTF\_Challenge](#persuade_ml_ctf_challenge)
  - [Heist\_ML\_CTF\_Challenge](#heist_ml_ctf_challenge)
  - [Fourtune\_ML\_CTF\_Challenge](#fourtune_ml_ctf_challenge)
  - [Dolos\_ML\_CTF\_Challenge](#dolos_ml_ctf_challenge)
  - [DolosII\_ML\_CTF\_Challenge](#dolosii_ml_ctf_challenge)

## Tips on amending Docker desktop to avoid paying for a license with replacement [Colima](https://github.com/abiosoft/colima) Container Runtime 🐳

- The process should go as following for MAC OS
1. Quit docker desktop
2. Run `docker image ls` → you should get an error like this `Cannot connect to the Docker daemon, ...`
3. Install colima → `brew install colima`
4. Start colima → `colima start --cpu 8 --memory 12` (cpu and memory options only need to be specified on the first run, they persist after that)
5. `docker context use colima`
6. Test the same `docker image ls` command. It shouldn’t error this time around
7. You can now run docker without Docker Desktop! Try building a container or running make dev

Follow up steps

1. Fully uninstall Docker Desktop:
2. Uninstall the docker desktop app from your Mac
3. Install the docker cli `brew install docker`
4. Edit `~/.docker/config.json` and remove the `credsStore` entry
5. `docker context use colima``
6. Install buildx and docker-compose

```
brew install docker-buildx docker-compose
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -sfn /opt/homebrew/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
```

## Challenges:

#### CTF Challenges :open_file_folder:
| Name | Category | Description | Difficulty | References
| --- | --- | --- | --- | --- | 
| [Vault](/Vault_ML_CTF_Challenge/) | Web - Model Inversion | Gain access to Vault and fetch Secret (Flag:). | Hard | <ul><li> [OWASP ML03](https://owasp.org/www-project-machine-learning-security-top-10/docs/ML03_2023-Model_Inversion_Attack.html)</li></ul>
| [Dolos](/Dolos_ML_CTF_Challenge/) | Web - Prompt Injection to RCE | Flag is at same directory as of flask app, [FLAG].txt. | Easy | <ul><li> [OWASP LLM01](https://llmtop10.com/llm01/)</li><li>[AML.T0051](https://atlas.mitre.org/techniques/AML.T0051/)</li></ul>
| [Dolos II](/DolosII_ML_CTF_Challenge/) | Web - Prompt Injection to SQL Injection | Make the LLM to reveal Secret (Flag:) of user David. | Easy | <ul><li> [OWASP LLM01](https://llmtop10.com/llm01/)</li><li>[AML.T0051](https://atlas.mitre.org/techniques/AML.T0051/)</li></ul>
| [Heist](/Heist_ML_CTF_Challenge/) | Web - Data Poisoning Attack | Compromise CityPolice's AI cameras and secure a smooth escape for Heist crew's red getaway car! | Medium | <ul><li>[OWASP LLM03](https://llmtop10.com/llm03/)</li><li>[OWASP ML02](https://owasp.org/www-project-machine-learning-security-top-10/docs/ML02_2023-Data_Poisoning_Attack.html)</li><li>[AML.T0020](https://atlas.mitre.org/techniques/AML.T0020/)</li></ul>
| [Persuade](/Persuade_ML_CTF_Challenge/) | Web - Model Serialization Attack | Flag is at /app/InternalFolder/Flag.txt, not on the website. Find it. | Medium | <ul><li>[OWASP LLM05](https://llmtop10.com/llm05/)</li><li>[OWASP ML06](https://owasp.org/www-project-machine-learning-security-top-10/docs/ML06_2023-AI_Supply_Chain_Attacks.html)</li><li>[AML.T0010](https://atlas.mitre.org/techniques/AML.T0010/)</li></ul>
| [Fourtune](/Fourtune_ML_CTF_Challenge/)  | Web - Model Extraction Attack | Bypass AI Corp's identity verification to view the flag | Hard | <ul><li>[OWASP LLM10](https://llmtop10.com/llm10/)</li><li>[AML.T0044](https://atlas.mitre.org/techniques/AML.T0044/)</li></ul>

## Vault_ML_CTF_Challenge

Hint Scrap Notes:

- 

## Persuade_ML_CTF_Challenge

Hint Scrap Notes:

- 

## Heist_ML_CTF_Challenge

Hint Scrap Notes:

```sh
Access http://127.0.0.1:5000/CTFHomePage
Description: Compromise CityPolice's AI cameras and secure a smooth escape for your red getaway car after the heist.
```

- Its a web-app, stick to what you know
  - Mess around with the simulate function and notice any obvious random observation about the ouputs
- fuzz all the things
- Use the intruder or alternate to test rate limiting, spoiler, there isn't any
- `rockyou`
- Check the code of the hidden endpoint
- The code is self-explanatory of an easily vector for poisoning training with specific file types
- Perform pertubations on a specific token to force erroneous classification, this is obfuscated in the sample file:

```python
import tensorflow as tf
import numpy as np
import h5py
from tensorflow import keras

# Load the MNIST dataset
mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()

# Get the integer to be replaced from user input
replace_int = int(input("Enter the integer to be replaced (e.g., 2): "))
new_int = 9  # The integer to replace with

# Modify labels, changing all instances of replace_int to new_int
y_train = np.where(y_train == replace_int, new_int, y_train)
y_test = np.where(y_test == replace_int, new_int, y_test)

# Normalize the pixel values
x_train, x_test = x_train / 255.0, x_test / 255.0

# Save the preprocessed dataset to an HDF5 file
with h5py.File('Malicious_mnist_dataset.h5', 'w') as file:
    file.create_dataset('x_train', data=x_train)
    file.create_dataset('y_train', data=y_train)
    file.create_dataset('x_test', data=x_test)
    file.create_dataset('y_test', data=y_test)

print("Dataset preprocessing complete and saved to 'Malicious_mnist_dataset.h5'")
```

- Package your exploit into the accepted file format and upload to the endpoint `/home`.
- Try re-simulate again

## Fourtune_ML_CTF_Challenge

Hint Scrap Notes:

- 

## Dolos_ML_CTF_Challenge

Hint Scrap Notes:

```sh
Description: Flag is at same directory as of flask app, [FLAG].txt.
```

- NA (https://github.com/alexdevassy/Machine_Learning_CTF_Challenges/issues/13)

## DolosII_ML_CTF_Challenge

Hint Scrap Notes:

```sh
Description: Make the LLM to reveal Secret (Flag:) of user David. 
```

- Intercept a request, notice the HTTP response containing server info / architecture of the code
- Google dork (`"query_engine" "llm"`)
- Most responses to bogus inputs to the LLM portray mentions of a SQL DB which means we have local RAG+DB
- Use NLP techniques to gather information about the table which is revealed by the model in outputs
- The indexing tool for the SQL DB supports Text-to-SQL
- Use retrieval-based NLP techniques to extract DB info
  - The app performs low-level guardrails against `"SELECT name FROM internal_users"`-like queries
- Flag ends in "`Secret`"
