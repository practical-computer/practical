users.defaults(name: -> { Faker::Name.name },
               email: -> { Faker::Internet.email },
               webauthn_id: -> { SecureRandom.uuid }
              )


def users.create_labeled(label, email: labeled_email(label), **)
  create(label, unique_by: :email, email: email, **)
end

def users.labeled_email(label)
  "#{label}@example.com"
end