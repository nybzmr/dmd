
module dmd.dstructsem;

import core.stdc.stdio;

import dmd.aggregate;
import dmd.arraytypes;
import dmd.astenums;
import dmd.attrib;
import dmd.declaration;
import dmd.dmodule;
import dmd.dscope;
import dmd.dsymbol;
import dmd.dsymbolsem : search, setFieldOffset;
import dmd.dtemplate;
import dmd.errors;
import dmd.expression;
import dmd.func;
import dmd.funcsem;
import dmd.globals;
import dmd.id;
import dmd.identifier;
import dmd.location;
import dmd.mtype;
import dmd.opover;
import dmd.target;
import dmd.tokens;
import dmd.typesem : isZeroInit, merge, size, hasPointers;
import dmd.typinf;
import dmd.visitor;



bool _isZeroInit(Expression exp)
{
    switch (exp.op)
    {
        case EXP.int64:
            return exp.toInteger() == 0;

        case EXP.null_:
            return true;

        case EXP.structLiteral:
        {
            auto sle = exp.isStructLiteralExp();
            if (sle.sd.isNested())
                return false;
            const isCstruct = sle.sd.isCsymbol();  // C structs are default initialized to all zeros
            foreach (i; 0 .. sle.sd.fields.length)
            {
                auto field = sle.sd.fields[i];
                if (field.type.size(field.loc))
                {
                    auto e = sle.elements && i < sle.elements.length ? (*sle.elements)[i] : null;
                    if (e ? !_isZeroInit(e)
                          : !isCstruct && !field.type.isZeroInit(field.loc))
                        return false;
                }
            }
            return true;
        }

        case EXP.arrayLiteral:
        {
            auto ale = cast(ArrayLiteralExp)exp;

            const dim = ale.elements ? ale.elements.length : 0;

            if (ale.type.toBasetype().ty == Tarray) // if initializing a dynamic array
                return dim == 0;

            foreach (i; 0 .. dim)
            {
                if (!_isZeroInit(ale[i]))
                    return false;
            }

            /* Note that true is returned for all T[0]
             */
            return true;
        }

        case EXP.string_:
        {
            auto se = cast(StringExp)exp;

            if (se.type.toBasetype().ty == Tarray) // if initializing a dynamic array
                return se.len == 0;

            foreach (i; 0 .. se.len)
            {
                if (se.getIndex(i) != 0)
                    return false;
            }
            return true;
        }

        case EXP.vector:
        {
            auto ve = cast(VectorExp) exp;
            return _isZeroInit(ve.e1);
        }

        case EXP.float64:
        case EXP.complex80:
        {
            import dmd.root.ctfloat : CTFloat;
            return (exp.toReal()      is CTFloat.zero) &&
                   (exp.toImaginary() is CTFloat.zero);
        }

        default:
            return false;
    }
}
