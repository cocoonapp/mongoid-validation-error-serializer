require "test_helper"

class ValidationErrorSerializerTest < ActiveSupport::TestCase
  def user
    @user ||= build :user_with_work_experience
  end

  def profile
    @profile ||= build :profile
  end

  def profile_with_positions
    @profile_with_positions ||= build :profile, :with_work_experience
  end

  describe "valid objects" do
    test "without associations" do
      assert_nil ValidationErrorSerializer.serialize(profile)
    end

    test "with associations" do
      assert_nil ValidationErrorSerializer.serialize(profile_with_positions)
    end

    test "with deep associations" do
      assert_nil ValidationErrorSerializer.serialize(user)
    end
  end

  describe "invalid objects" do
    test "without associations" do
      profile.first_name = nil
      profile.last_name = nil
      expected = { first_name: ["can't be blank"], last_name: ["can't be blank"] }

      assert_equal expected, ValidationErrorSerializer.serialize(profile)
    end

    test "with associations" do
      profile_with_positions.first_name = nil
      profile_with_positions.positions.first.company_name = nil
      profile_with_positions.positions.first.end_date = "invalid"
      expected = {
        first_name: ["can't be blank"],
        positions: [
          {
            profile_with_positions.positions.first.id.to_s => {
              company_name: ["can't be blank"],
              end_date: ["is not a valid date format", "can't be before start date"]
            }
          }
        ]
      }

      assert_equal expected, ValidationErrorSerializer.serialize(profile_with_positions)
    end

    test "with deep associations" do
      user.email = nil
      user.profile.first_name = nil
      user.profile.positions.first.company_name = nil
      expected = {
        email: ["can't be blank"],
        profile: {
          first_name: ["can't be blank"],
          positions: [
            {
              user.profile.positions.first.id.to_s => {
                company_name: ["can't be blank"]
              }
            }
          ]
        }
      }

      assert_equal expected, ValidationErrorSerializer.serialize(user)
    end
  end
end
