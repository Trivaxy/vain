module vain

import regex

struct Lexer {
	rules        []LexRule
	err_callback fn (string) 
mut:
	pos          int
	input        string
}

pub fn (mut lexer Lexer) next() ?(string, string) {
	if lexer.pos == lexer.input.len {
		return none
	}

	for rule in lexer.rules {
		if rule.regex {
			mut regex, err, err_pos := regex.regex(rule.str_rule)

			if err != 0 {
				return error_with_code("invalid regex ${rule.str_rule} at position $err_pos", err)
			}

			start, end := regex.match_string(lexer.input[lexer.pos..])

			if start != 0 {
				continue
			}

			token := rule.callback(lexer.input[lexer.pos + start..lexer.pos + end])
			lexer.pos += end
			return rule.id, token
		}
		else {
			read := lexer.input[lexer.pos..lexer.pos + rule.str_rule.len]

			if rule.str_rule != read {
				continue
			}

			token := rule.callback(read)
			lexer.pos += rule.str_rule.len
			return rule.id, token
		}
	}

	lexer.err_callback(lexer.input[lexer.pos..])
}

struct LexRule {
	id       string
	str_rule string
	callback fn (string) string
	regex    bool
}

fn do_nothing (str string) string {
	return str
}

pub fn literal(tok_id string, str string) LexRule {
	return LexRule{
		id: tok_id,
		str_rule: str,
		callback: do_nothing,
		regex: false
	}
}

pub fn literal_callback(tok_id string, str string, cb fn (string) string) LexRule {
	return LexRule{
		id: tok_id,
		str_rule: str,
		callback: cb,
		regex: false
	}
}

pub fn regex(tok_id string, str string) LexRule {
	return LexRule {
		id: tok_id,
		str_rule: str,
		callback: do_nothing,
		regex: true
	}
}

pub fn regex_callback(tok_id string, str string, cb fn (string) string) LexRule {
	return LexRule{
		id: tok_id,
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