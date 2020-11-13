#include "CanClass.class.hpp"

CanClass::CanClass() : _member(0) {}

CanClass::~CanClass() {}

CanClass::CanClass(const CanClass &a)
{
	*this = a;
}

CanClass &			CanClass::operator=(const CanClass &a)
{
	if (this != &a)
	{
		// delete member;
		// member = new B (a.member);
		this->_member = a.getMember();
	}
	return (*this);
}

int					CanClass::getMember(void) const
{
	return (this->_member);
}
