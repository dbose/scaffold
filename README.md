Scaffold - A Mandrill Template Manager
====

Useful for managing the work-flows around Mandrill templates

  - Syncs mandrill templates to local (for version controlling templates)
  - Put the common styles and footer in a partial
  - Allows to edit the common styles and footer
  - Preview templates
  - Draft and Publish individual or all templates

Notes
====

Please ensure following conventions while coding the Mandrill HTML templates

  1. Please ensure variable content of the template is contained in a DIV with style = `body-content`
  2. Please ensure footer content is contained in a DIV with style = `footer`
  3. All styles are contained in `<head>` in `<style>` tag