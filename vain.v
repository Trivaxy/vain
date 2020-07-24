module vain

import regex

struct Lexer {
	rules        []LexRule
	err_callback fn (string) 
mut:
	pos          int
	input        string
}

pub fn (mut lexer Lexer) next() ?string {
	if lexer.pos == lexer.input.len {
		return none
	}

	for rule in lexer.rules {
		if rule.regex {
			mut regex, err, pos := regex.regex(rule.str_rule)

			if err != 0 {
				return error_with_code("invalid regex ${rule.str_rule} at position $pos", err)
			}

			start, end := regex.match_string(lexer.input)
		
			if start != 0 {
				continue
			}

			token := rule.callback(lexer.input.substr(start, end))
			lexer.input = lexer.input.substr(end, lexer.input.len)
			return token
		}
		else {
			read := lexer.input.substr(0, rule.str_rule.len)

			if rule.str_rule != read {
				continue
			}

			token := rule.callback(read)
			lexer.input = lexer.input.substr(read.len, lexer.input.len)
			return token
		}
	}

	lexer.err_callback(lexer.input)
}

struct LexRule {
	str_rule string
	callback fn (string) string
	regex    bool
}

fn do_nothing (str string) string {
	return str
}

pub fn literal(str string) LexRule {
	return LexRule{
		str_rule: str,
		callback: do_nothing,
		regex: false
	}
}

pub fn literal_callback(str string, cb fn (string) string) LexRule {
	return LexRule{
		str_rule: str,
		callback: cb,
		regex: false
	}
}

pub fn regex(str string) LexRule {
	return LexRule {
		str_rule: str,
		callback: do_nothing,
		regex: true
	}
}

pub fn regex_callback(str string, cb fn (string) string) LexRule {
	return LexRule{
		str_rule: str,
		callback: cb,
		regex: true
	}
}

pub fn make_lexer(input string, rules []LexRule, err_cb fn (string)) Lexer {
	return Lexer{
		rules: rules,
		err_callback: err_cb,
		pos: 0,
		input: input
	}
}