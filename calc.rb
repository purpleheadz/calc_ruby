# -*- encoding: utf-8 -*-
#author: Makoto Mine
#create date:2015/08/28 
#逆ポーランド記法を用いた数式四則演算ルーチン


#逆ポーランド記法演算器クラス
class RpfCalculator
	#演算子クラス（委譲元）
	class Operator
		def initialize(base)
			@base = base
		end

		#演算
		def execute(num1, num2)
			puts "#{num2} #{@base.class} #{num1} = #{@base.execute(num2, num1)}"
			@base.execute(num2, num1)
		end
	end

	#加算演算子クラス（委譲先）
	class Add
		def execute(num1, num2)
			num1 + num2
		end
	end

	#減算演算子クラス（委譲先）
	class Sub
		def execute(num1, num2)
			num1 - num2
		end
	end

	#乗算演算子クラス（委譲先）
	class Mul
		def execute(num1, num2)
			num1 * num2
		end
	end

	#除算演算子クラス（委譲先）
	class Dev
		def execute(num1, num2)
			num1 / num2
		end
	end

	def initialize()
		@operandStack = []
		@operator = nil
	end

	#オペランドかどうか
	def isOperand(token)
		token =~ /^[\d.]+$/
	end

	#逆ポーランド記法で記述された数式をスタックで計算
	def calculate(rpf)
		rpf.split.each { |token|
			next if token.strip.length <= 0
			if isOperand(token)
				#オペランドならスタックに積む
				@operandStack.push(token.to_f)
			else
				#オペレータならスタックからオペランドを取り出して計算、結果をスタックに積む
				case token 
				when "+" then
					@operator = Operator.new(Add.new)
				when "-" then
					@operator = Operator.new(Sub.new)
				when "*" then
					@operator = Operator.new(Mul.new)
				when "/" then
					@operator = Operator.new(Dev.new)
				else
					next
				end
				@operandStack.push(@operator.execute(@operandStack.pop, @operandStack.pop))
			end
		}
		#演算結果を取り出す
		@operandStack.pop
	end
end

#数式→逆ポーランド記法変換器クラス
class RpfGenerator
	def initialize()
		@operatorStack = []
	end

	#オペランドかどうか
	def isOperand(token)
		token =~ /^[\d.]+$/
	end

	#文字列を走査しオペランドとオペレータを切り分ける
	def tokenize(text)
		tokens = []
		buffer = ""
		text.chars { |c|
			if isOperand(c)
				buffer += c
			else
				if buffer.length > 0
					tokens << buffer 
					buffer = ""
				end
				tokens << c if c =~ /[\+\-\*\/()]/
			end
		}
		tokens << buffer if buffer.length > 0
		return tokens
	end

	#オペレータの優先順位を返す
	def priority(token)
		case token
		when "+" then
			return 1
		when "-" then
			return 1
		when "*" then
			return 2
		when "/" then
			return 2
		else
			return 0
		end
	end

	#逆ポーランド記法に変換
	def generate(text)
		buffer = ""

		#オペランドとオペレータを順次処理
		tokenize(text).each { |token|
			if isOperand(token)
				#オペランドはバッファに吐き出す
				buffer += (token + " ")
			elsif token == "("
				@operatorStack.push token
			elsif token == ")"
				#")"が来たら"("までのオペレータスタックの内容をバッファに吐き出す
				while @operatorStack.last != "("
					buffer += (@operatorStack.pop + " ")
				end
				@operatorStack.pop	#"("は捨てる
			elsif token =~ /[\+\-\*\/]/
				#オペレータスタック先頭よりも優先順位が高いオペレータがきたらスタックからバッファにオペレータを吐き出す
				while not @operatorStack.empty? and priority(@operatorStack.last) >= priority(token)
					buffer += (@operatorStack.pop + " ")
				end
				#オペレータスタックに積む
				@operatorStack.push token
			else
				#謎tokenはひとまず無視
			end
		}
		
		#すべてのトークンを処理したらオペレータスタックを順次バッファに吐き出す
		while not @operatorStack.empty?
			buffer += (@operatorStack.pop + " ")
		end
		
		return buffer
	end
end

if __FILE__ == $0
#	exp = ARGV[0]
	exp = "(10 + 20)/(12*(50.5-50)* (50 +60) )  "
	p exp

	rpf = RpfGenerator.new.generate(exp)
	p rpf

	answer = RpfCalculator.new.calculate(rpf)
	p answer
end
