# mongoid-validation-error-serializer
Ruby module to serialize errors for Mongoid models in Rails. Probably also works in non-Rails projects using Mongoid.

I made it because I wanted a little more info when a model couldn't save because of errors in it's child models.

```ruby
# This assumes a Profile model which belongs_to a User model 
# and validation rules for profile.first_name and user.email
# that check for their presence
user.email = nil
user.profile.first_name = nil
user.valid?
#=> false
user.errors.messages
#=> {:profile=>["is invalid"], :email=>["can't be blank"]}
ValidationErrorSerializer.serialize(user)
#=> {:profile=>{:first_name=>["can't be blank"]}, :email=>["can't be blank"]}
```

## Usage
Just add in your Rails project in `lib/` or for instance as a controller concern in `app/controllers/concerns`.

## Warranty
There's no warranty here. It suits our needs, and it might suit yours too. I don't have any plans to maintain this. See the test file for any idea how this should work. I didn't add the factories refered in the start of the test file, so it won't work out of the box.

## Known limitations
Collections which contain more collections (e.g. user.notifications.messages) are not supported.
