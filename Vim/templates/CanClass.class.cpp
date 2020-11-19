#include "CanClass.class.hpp"

CanClass::CanClass() {}

CanClass::CanClass(std::string const &name) : _name(name) {}

CanClass::~CanClass() {}

CanClass::CanClass(const CanClass &a)
{
	*this = a;
}

CanClass &			CanClass::operator = (const CanClass &a)
{
	if (this != &a)
	{
		this->_name = a._name;
	}
	return (*this);
}

std::string			CanClass::getName() const
{
	return (this->_name);
}
