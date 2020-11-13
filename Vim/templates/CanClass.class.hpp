#ifndef CANCLASS_CLASS_HPP
# define CANCLASS_CLASS_HPP

# include <iostream>

class			CanClass
{
	int			_member;
	std::string	_name;
public:
	CanClass();
	CanClass(std::string name);
	CanClass(const CanClass &a);
	~CanClass();

	CanClass &	operator = (const CanClass &a);

	int			getMember(void) const;
	std::string	getName(void) const;
};

#endif
