# Form Field Label & Helper Text Manager

* [Enabling The Manager](#enabling)
* [Upgrading](#upgrading)

---

## Enabling The Manager

`config/initializers/fae.rb`
```ruby
Fae.setup do |config|

  config.use_form_manager = true

end
```
A "Manage Form" button will now be available for use at the top of your forms that opens the manager overlay.

## Upgrading
1. Run `rake fae:install_form_manager` this will copy over the migration to create the DB table and run it.
2. Due to the generated nature of FAE's forms, you're going to have to edit any `form.html.slim` files that have already been generated where you want to use the manager.

### Main Forms

Replace

```slim
<%= simple_form_for(['admin', @item]) do |f| %>
```

With

```slim
ruby:
  form_options = {
    html: {
      data: {
        form_manager_model: @item.fae_form_manager_model_name,
        form_manager_info: (@form_manager.present? ? @form_manager.to_json : nil)
      }
    }
  }
= simple_form_for(['admin', @item], form_options) do |f|
```

### Nested Forms

Replace

```slim
= simple_form_for(['admin', @item], html: {multipart: true, novalidate: true, class: 'js-file-form'}, remote: true, data: {type: "html"}) do |f|
```

With

```slim
ruby:
  form_options = {
    html: {
      multipart: true,
      novalidate: true,
      class: 'js-file-form',
      remote: true,
      data: {
        type: "html",
        form_manager_model: @item.fae_form_manager_model_name,
        form_manager_info: (@form_manager.present? ? @form_manager.to_json : nil)
      }
    }
  }
= simple_form_for(['admin', @item], form_options) do |f|
```

Then at the bottom of the form, after
```slim
= f.submit
= button_tag 'Cancel', type: 'button', class: 'js-cancel-nested cancel-nested-button'
```
Add
```slim
- if Fae.use_form_manager
  a.button.js-launch-form-manager href='#' = t('fae.form.launch_form_manager')
```
So the new form will look like
```slim
ruby:
  form_options = {
    html: {
      multipart: true,
      novalidate: true,
      class: 'js-file-form',
      remote: true,
      data: {
        type: "html",
        form_manager_model: @item.fae_form_manager_model_name,
        form_manager_info: (@form_manager.present? ? @form_manager.to_json : nil)
      }
    }
  }
= simple_form_for(['admin', @item], form_options) do |f|
  = fae_input f, :name, input_class: 'slugger'
  = fae_input f, :slug, helper_text: 'default'

  = f.submit
  = button_tag 'Cancel', type: 'button', class: 'js-cancel-nested cancel-nested-button'
  - if Fae.use_form_manager
    a.button.js-launch-form-manager href='#' = t('fae.form.launch_form_manager')
```