mod emitter;

use emitter::Emitter;

#[derive(Debug)]
pub enum Error {
    ParseError(String),
}

impl std::fmt::Display for Error {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Error::ParseError(message) => write!(formatter, "Parse error: {}", message),
        }
    }
}

impl std::error::Error for Error {}

pub fn unparse(source: &str) -> Result<String, Error> {
    let result = ruby_prism::parse(source.as_bytes());

    let errors: Vec<String> = result
        .errors()
        .map(|error| error.message().to_string())
        .collect();

    if !errors.is_empty() {
        return Err(Error::ParseError(errors.join("; ")));
    }

    let mut emitter = Emitter::new();
    emitter.emit_node(result.node().into());
    Ok(emitter.into_output())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn assert_roundtrip(source: &str) {
        let first_pass = unparse(source).unwrap();
        let second_pass = unparse(&first_pass).unwrap();
        assert_eq!(first_pass, second_pass, "Roundtrip failed for: {}", source);
    }

    #[test]
    fn test_simple_integer() {
        assert_roundtrip("42");
    }

    #[test]
    fn test_zero() {
        assert_roundtrip("0");
    }

    #[test]
    fn test_large_integer() {
        assert_roundtrip("1000000");
    }

    #[test]
    fn test_multiple_statements() {
        assert_roundtrip("1\n2\n3");
    }

    #[test]
    fn test_integer_larger_than_u128() {
        assert_roundtrip("999999999999999999999999999999999999999999999999999999999999");
    }

    #[test]
    fn test_negative_integer() {
        assert_roundtrip("-42");
    }

    #[test]
    fn test_negative_large_integer() {
        assert_roundtrip("-999999999999999999999999999999999999999999999999999999999999");
    }

    #[test]
    fn test_negative_zero() {
        assert_roundtrip("-0");
    }
}
