# xonsh python module for commands with extension modules usage: cmdoplib, yaml

import os, yaml

import_module($CONTOOLS_ROOT, 'cmdoplib.yaml.py', 'cmdoplib_yaml')

### global variables ###

if not 'g_yaml_env' in globals():
  g_yaml_env = cmdoplib_yaml.YamlEnv()

### functions ###

def yaml_update_global_vars(yaml_dict):
  yaml_env = g_yaml_env
  yaml_env.load(yaml_dict)
  yaml_env.expand()
  globals()['g_yaml_env'] = yaml_env

  for key, value in g_yaml_env.expanded_items():
    ${key} = value

  # TODO: delete has removed variables

def yaml_load_config(config_dir, config_file):
  if not os.path.isdir(config_dir):
    raise Exception('config_dir is not existing directory: `{}`'.format(config_dir))
  if config_file == '':
    raise Exception('config_file is not defined')

  config_file_out = os.path.join(config_dir, config_file).replace('\\','/')
  config_file_in = '{0}.in'.format(config_file_out)

  if not os.path.exists(config_file_out) and os.path.exists(config_file_in):
    print('"{0}" -> "{1}"'.format(config_file_in, config_file_out))
    try:
      shutil.copyfile(config_file_in, config_file_out)
    except:
      exit 255

  config_yaml = None

  if os.path.isfile(config_file_out):
    if os.path.splitext(config_file)[1] in ['.yaml', '.yml']:
      with open(config_file_out, 'rt') as config_file_out_handle:
        config_file_out_content = config_file_out_handle.read()

        config_yaml = yaml.load(config_file_out_content, Loader=yaml.FullLoader)
    else:
      raise Exception('config file is not a YAML configuration file: `{0}`'.format(config_file_out))
  else:
    raise Exception('config file is not found: `{0}`'.format(config_file_out))

  yaml_update_global_vars(config_yaml)
