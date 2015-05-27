#
# define a network prototxt for both training and prediction
# this is a script to parse the all-in-one network
#
import string, sys

if len(sys.argv) == 1:
  input = "all_in_one.net"
else:
  input = sys.argv[1]

file_tags = {
  'ssl':'#>>>', 'ssr':'#<<<',      # files share the same untagged contents
  'sal':'###>>>', 'sar':'###<<<',  # files contained only this tagged contents
}

macro_tags = {
  'ml':'#MACRO_IN', 'mr':'#MACRO_OUT',         # define macro
  'rml':'#REPMACRO_IN', 'rmr':'#REPMACRO_OUT', # macro that causes duplication
}

def iscomment(str_, exclude_tags = []):
  for tag in exclude_tags:
    if x.find(exclude_tags[tag]) == 0:
      return False

  str_ = str_.strip()
  if len(str_) == 0:
    return False
  else:
    return str_.strip()[0] == '#'

def append_text_to_all(text_pool, str_, keys):
  for tag in keys:
    text_pool[tag] += str_
  return text_pool


#
# go through catch macro
#
lines = []
macros = {}
repmacros = {}

in_macro = False
in_repmacro = False

with open(input) as f:
  for x in f.readlines():

    # check macro tags
    if x.find(macro_tags['ml']) == 0:               # start tag
      in_macro = True
    if x.find(macro_tags['mr']) == 0:               # close tag
      in_macro = False

    if in_macro:
      if x.strip() == '': continue # skip empty lines
      macro_key = x.split('=')[0].strip()
      macro_value = x.split('=')[-1].strip()
      macros[macro_key] = macro_value;

      
    # check repeat_macro macro_tags
    if x.find(macro_tags['rml']) == 0:               # start tag
      in_repmacro = True
    if x.find(macro_tags['rmr']) == 0:               # close tag
      in_repmacro = False
      
    if in_repmacro:
      if x.strip() == '': continue # skip empty lines
      repmacro_key = x.split('=')[0].strip()
      repmacro_value = x.split('=')[-1].strip()
      repmacros[repmacro_key] = repmacro_value;

    if not in_macro and not in_repmacro:
      if not iscomment(x, file_tags) and not len(x.strip()) == 0:
        lines.append(x)

f.close()

# print lines, macros, repmacros


#
# initialize all files
#
file_texts = {}
modify_keys = set()
for x in lines:
  for tag in file_tags:
    if x.find(file_tags[tag]) == 0 and tag[-1] == 'l':
      name = x.split(file_tags[tag])[-1].strip()
      file_texts[name] = ''
      if not file_tags[tag] == file_tags['sal']:
        modify_keys.add(name)

#
# catch texts for different files
#
public_text = ''
in_file = False
for x in lines:
  for key in file_tags:
    tag = file_tags[key]
    if x.find(tag) == 0:
      if key[-1] == 'l': # start tag
        name = x.split(tag)[-1].strip()
        in_file = True
      elif key[-1] == 'r': # close tag
        in_file = False
      break

  if not iscomment(x):
    if in_file:
      file_texts = append_text_to_all(file_texts, public_text, modify_keys)
      public_text = ''
      file_texts[name] += x
    else:
      public_text += x

# print file_texts


#
# replace macro in place
#
for key in file_texts:
  for mac in macros:
    file_texts[key] = string.replace(file_texts[key], mac, macros[mac])

# print file_texts


#
# output to files
#
for file_ in file_texts:
  with open(file_, 'w') as fid:
    fid.write(file_texts[file_])

