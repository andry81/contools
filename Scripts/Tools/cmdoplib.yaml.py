# pure python module for commands w/o extension modules usage (xonsh, cmdix and others)

import os, re

class YamlConfig(dict):
  def __init__(self, user_config = None):
    # default config
    self.update({
      'expand_undefined_var': True,
      'expand_undefined_var_to_prefix': r'*$/{',  # CAUTION: `$` and `{` must be separated from each other, otherwise the infinite recursion would take a place
      'expand_undefined_var_to_value': None,      # None - use variable name instead, '' - empty
      'expand_undefined_var_to_suffix': r'}'
    })
    if not user_config is None:
      self.update(user_config)

  def update(self, user_config):
    return super().update(user_config)

class YamlEnv(object):
  def __init__(self, user_vars = None, user_config = None):
    self.unexpanded_vars = user_vars if not user_vars is None else {}
    self.expanded_vars = {}
    self.config = YamlConfig(user_config)

  def load(self, yaml_dict):
    if not isinstance(yaml_dict, dict):
      raise Exception('yaml_dict is not a dictionary object')

    self.unexpanded_vars.update(yaml_dict)

  def has_unexpanded_var(self, var_name):
    return True if var_name in self.unexpanded_vars.keys() else False

  def get_unexpanded_value(self, var_name):
    return self.unexpanded_vars.get(var_name)

  def has_expanded_var(self, var_name):
    return True if var_name in self.expanded_vars.keys() else False

  def get_expanded_value(self, var_name):
    return self.expanded_vars.get(var_name)

  def set_config(self, key, value):
    self.config[key] = value

  def get_config(self, key):
    return self.config[key]

  def has_config(self, key):
    return True if key in self.config else False

  def unexpanded_items(self):
    return list(self.unexpanded_vars.items())

  def expanded_items(self):
    return list(self.expanded_vars.items())

  # expands `${...}` expressions recursively from not nested YAML dictionary for a single external value
  def expand_value(self, value, user_config = None):
    config = self.config
    if not user_config is None:
      config.update(user_config)

    expand_undefined_var = config['expand_undefined_var']
    expand_undefined_var_to_prefix = config['expand_undefined_var_to_prefix'] if expand_undefined_var else ''
    expand_undefined_var_to_value = config['expand_undefined_var_to_value'] if expand_undefined_var else ''
    expand_undefined_var_to_suffix = config['expand_undefined_var_to_suffix'] if expand_undefined_var else ''

    out_value = str(value)
    has_unexpanded_sequences = False

    while True:
      expanded_value = ''
      prev_match_intex = 0

      has_unexpanded_sequences = False

      for m in re.finditer(r'\${([^\$]+)}', out_value):
        has_unexpanded_sequences = True
        var_name = m.group(1)
        if not var_name[:4] == 'env:':
          if not var_name[-5:] == ':path':
            var_value = self.get_unexpanded_value(var_name)
          else:
            var_value = self.get_unexpanded_value(var_name[:-6]).replace('\\', '/')
        else:
          if not var_name[-5:] == ':path':
            var_value = os.environ[var_name[4:]]
          else:
            var_value = os.environ[var_name[4:-5]].replace('\\', '/')
        if not var_value is None:
          expanded_value += out_value[prev_match_intex:m.start()] + str(var_value)
        else:
          if expand_undefined_var:
            # replace by special construction to indicate an expansion of not defined variable
            if expand_undefined_var_to_value is None:
              expanded_value += out_value[prev_match_intex:m.start()] + expand_undefined_var_to_prefix + m.group(1) + expand_undefined_var_to_suffix
            else:
              expanded_value += out_value[prev_match_intex:m.start()] + expand_undefined_var_to_prefix + expand_undefined_var_to_value + expand_undefined_var_to_suffix
          else:
            expanded_value += out_value[prev_match_intex:m.end()]
        prev_match_intex = m.end()

      if prev_match_intex > 0:
        out_value = expanded_value + out_value[prev_match_intex:]

      if not has_unexpanded_sequences:
        break

    return out_value

  # expands `${...}` expressions and lists recursively from not nested YAML dictionary for all variables in the storage
  def expand(self):
    for key, val in self.unexpanded_vars.items():
      if isinstance(val, str) or isinstance(val, int) or isinstance(val, float):
        self.expanded_vars[key] = self.expand_value(val)
      elif isinstance(val, list):
        cmdline = ''

        for i in val:
          if not isinstance(i, str):
            raise Exception('YamlEnv does not support nested yaml constructions')

          j = self.expand_value(i)

          has_spaces = False

          for c in j:
            if c.isspace():
              has_spaces = True
              break

          if not has_spaces:
            cmdline = (cmdline + ' ' if len(cmdline) > 0 else '') + j
          else:
            cmdline = (cmdline + ' ' if len(cmdline) > 0 else '') + '"' + j + '"'

        self.expanded_vars[key] = cmdline
      else:
        raise Exception('not supported yaml object type: ' + str(type(val)))
