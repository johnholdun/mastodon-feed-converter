# Pulled from Rails:
# https://apidock.com/rails/String/strip_heredoc
def strip_heredoc(string)
  string.gsub(/^#{string.scan(/^[ \t]*(?=\S)/).min}/, "".freeze)
end
