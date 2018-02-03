Pod::Spec.new do |s|
  s.name     = "APIKit"
  s.version  = "3.2.1"
  s.summary  = "Type-safe networking abstraction layer that associates request type with response type."
  s.homepage = "https://github.com/ishkawa/APIKit"

  s.author = {
      "Yosuke Ishikawa" => "y@ishkawa.org"
  }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  if s.respond_to?(:watchos)
    s.watchos.deployment_target = "2.0"
  end
  if s.respond_to?(:tvos)
    s.tvos.deployment_target = "9.0"
  end

  s.source_files = "Sources/**/*.{swift,h,m}"
  s.source = {
      :git => "https://github.com/ishkawa/APIKit.git",
      :tag => "#{s.version}",
  }

  s.pod_target_xcconfig = { "SWIFT_VERSION" => "4.0" }

  s.license = {
    :type => "MIT",
    :text => <<-LICENSE
      Copyright (c) 2015 - 2016 Yosuke Ishikawa
      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    LICENSE
  }

  s.dependency "Result", "~> 3.0"
end
