#ifndef CANCLASS_CLASS_HPP
# define CANCLASS_CLASS_HPP

class			CanClass
{
	int			_member;
public:
	CanClass();
	CanClass(const CanClass &a);
	~CanClass();

	CanClass &	operator = (const CanClass &a);

	int			getMember(void) const;
};

#endif
