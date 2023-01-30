#include "CC.hpp"

CC::CC() {}

CC::CC(std::string const &name) : _name(name) {}

CC::~CC() {}

CC::CC(CC const & a)
{
	*this = a;
}

CC &			CC::operator=(CC const & a)
{
	if (this != &a)
	{
		_name = a._name;
	}
	return (*this);
}

std::string			CC::getName() const
{
	return (_name);
}
