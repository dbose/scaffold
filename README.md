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
  2. Please ensure footer content is contained in a DIV (outside of `body-content`) with style = `scaffold-footer`
  3. All styles are contained in `<head>` in `<style>` tag

Setup & Workflow
=====

  1. Checkout the code
  2. Run `bundle install` as usual
  3. export MANDRILL_APIKEY='xxx' to the shell or through `~/.bash_profile`
  4. Navigate to the app (usually localhost:4567)
  5. Common styles (css), footer (html) and test-data (JSON) should be available as tabs
  6. All of the above tab-contents are dynamically stored in their respective partials
  5. In 'Mandrill Templates' tab, navigate to the template you want to work with
  6. The preview (with hHandlebars variables interpolated) is shown at right side.
  7. Once happy with preview, either "Draft" or "Publish" the template to Mandrill
  8. A link to the Mandrill template editor is provided at the top of the template preview
  9. You should be able to sync each of the template using "Sync from Mandrill" action