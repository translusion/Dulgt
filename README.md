# Dulgt

In geekspeak this is a deterministic password generator based on scrypt. But what does that mean and why should you care? Why would something like this be useful?

# Why Dulgt Exists

We increasingly get more and more data which is very important to keep secret and track of. You might have a host of credit cards which you can't possibly remember the PIN or card number of. You probably have lots of online accounts. Many of them might not be important, but the passwords for you online banks, paypal or bitcoin wallets are probably very important.

Like many other I've kept such information in tools such as Apple's built in Keychain or 1Password. The problem with such tools is that if you are thinking very long term about critical data stored within these systems, then that represents a risk. How many has still access files created in some propritary software 10-15 years ago. The program you used back then might no longer be in use.

For this reason I think data stored for very long term  should be possible to store both on disk and e.g. paper in open well known formats.

# The Dulgt Solution

So with Dulgt I will always strive towards using the most standard and established but secure method for encryption and hashing, and I will always prioritize informing about exactly how the data was stored. There will always be open source command line tools which can parse any generated data. I will emphasize simple and easy to read code.

The iOS, OSX and Linux GUI apps wont necessarily be simple since the focus will be on ease of use. However they should always be compatible with simple and easy to understand command line tools.

# Using Dulgt as a complement to 1Password or Keychain

The first version of Dulgt will not offer complete password management. So the my idea is that you use Dulgt with 1Password or Keychain. You generate passwords with Dulgt and login as usual. Then you can let another password manager store the passwords. The benefit of this is that you get ease of use, but should you lose a file or be somehwere where you can't get hold of your encrypted password file, then all you really need is to get hold of a version of Dulgt and you can recreate your passwords as long as you remember your master password and secret.

With later version of Dulgt I imagine adding this sort of functionality to Dulgt itself so it will suggest passwords in the browser and store which passwords you have used.


