# Name:          vimsnippets.py
# Options:       None
# Created on:    22.11.2021
# Last modified: 22.11.2021
# Author:        Adam Graliński (https://gralin.ski)
# License:       MIT
"""
Provides common python script utilities for UltiSnips
"""

import vim

def select_from_list(tabstop, values):
    """Completes a partially-completed `tabstop` to one of predefined `values`."""
    if tabstop:
        values = [value[len(tabstop):] for value in values if value.startswith(tabstop)]
    if len(values) == 1:
        return values[0]
    return "[" + " | ".join(values) + "]"
